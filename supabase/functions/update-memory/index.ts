//// # update-memory Edge Function
//// Internal embedding writer for Memory. Server-only. Authorized by the project secret key on the
//// apikey header, then runs as service_role to update row embeddings. Never called by a browser or a user.
//// Actions: { action: "set_memory_embedding", id, sentence } and { action: "update_memory_embedding_queue", batch? }.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const model = new Supabase.ai.Session("gte-small");

function JsonResponse(status: number, body: object): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
  });
}

async function Embed(text: string): Promise<number[]> {
  return await model.run(text, { mean_pool: true, normalize: true }) as number[];
}

function ConstantTimeEqual(a: string, b: string): boolean {
  const encoder = new TextEncoder();
  const aBytes = encoder.encode(a);
  const bBytes = encoder.encode(b);
  if (aBytes.length !== bBytes.length) return false;
  let diff = 0;
  for (let i = 0; i < aBytes.length; i++) diff |= aBytes[i] ^ bBytes[i];
  return diff === 0;
}

Deno.serve(async (req: Request) => {
  try {
    const url = Deno.env.get("SUPABASE_URL") || "";
    const secretKey = JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") || "{}")["default"] || "";
    if (url === "" || secretKey === "") {
      return JsonResponse(500, { error: "Missing SUPABASE_URL or SUPABASE_SECRET_KEYS" });
    }

    const presented = req.headers.get("apikey") || "";
    if (!ConstantTimeEqual(presented, secretKey)) {
      return JsonResponse(401, { error: "unauthorized" });
    }

    const admin = createClient(url, secretKey);
    const body = await req.json().catch(() => ({}));
    const action = typeof body.action === "string" ? body.action : "";

    if (action === "set_memory_embedding") {
      const id = Number(body.id);
      const sentence = typeof body.sentence === "string" ? body.sentence : "";
      if (!(id > 0) || sentence === "") {
        return JsonResponse(400, { error: "id and sentence required" });
      }
      const embedding = JSON.stringify(await Embed(sentence));
      const { data, error } = await admin.rpc("set_memory_embedding", { p_id: id, p_embedding: embedding });
      if (error) return JsonResponse(500, { error: error.message });
      return JsonResponse(200, { id: data });
    }

    if (action === "update_memory_embedding_queue") {
      const batch = Number(body.batch) > 0 ? Number(body.batch) : 10;
      const { data: rows, error } = await admin.rpc("get_memory_embedding_queue", { p_limit: batch });
      if (error) return JsonResponse(500, { error: error.message });
      let processed = 0;
      for (const row of (rows ?? []) as Array<{ id: number; sentence: string }>) {
        const embedding = JSON.stringify(await Embed(row.sentence));
        const { error: upErr } = await admin.rpc("set_memory_embedding", { p_id: row.id, p_embedding: embedding });
        if (upErr) return JsonResponse(500, { error: upErr.message, processed });
        processed++;
      }
      return JsonResponse(200, { processed });
    }

    return JsonResponse(400, { error: `unknown action: ${action}` });
  } catch (err) {
    return JsonResponse(500, { error: err instanceof Error ? err.message : String(err) });
  }
});
