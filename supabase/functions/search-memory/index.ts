//// # search-memory Edge Function
//// User-facing semantic search for Memory. Runs as the caller: it forwards the caller's user JWT to
//// PostgREST, so the search RPC executes under that user's RLS. No secret key. verify_jwt is off; the
//// caller's JWT and RLS are the gate, so an anon caller sees nothing.
//// Request: { query, mode?: "semantic" | "hybrid", threshold?, count? }.

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

Deno.serve(async (req: Request) => {
  try {
    const url = Deno.env.get("SUPABASE_URL") || "";
    const publishableKey = JSON.parse(Deno.env.get("SUPABASE_PUBLISHABLE_KEYS") || "{}")["default"] || "";
    if (url === "" || publishableKey === "") {
      return JsonResponse(500, { error: "Missing SUPABASE_URL or SUPABASE_PUBLISHABLE_KEYS" });
    }

    // Run as the caller: forward their user JWT so PostgREST applies their RLS.
    const authorization = req.headers.get("Authorization") || "";
    const supabase = createClient(url, publishableKey, {
      global: { headers: { Authorization: authorization } },
    });

    const body = await req.json().catch(() => ({}));
    const query = typeof body.query === "string" ? body.query : "";
    if (query === "") return JsonResponse(400, { error: "query required" });
    const mode = body.mode === "hybrid" ? "hybrid" : "semantic";
    const threshold = typeof body.threshold === "number" ? body.threshold : 0.5;
    const count = typeof body.count === "number" ? body.count : 20;

    const embedding = JSON.stringify(await Embed(query));

    if (mode === "semantic") {
      const { data, error } = await supabase.rpc("search_memory_embedding", {
        p_query_embedding: embedding,
        p_match_threshold: threshold,
        p_match_count: count,
      });
      if (error) return JsonResponse(500, { error: error.message });
      return JsonResponse(200, { mode: "semantic", results: data ?? [] });
    }

    const { data, error } = await supabase.rpc("search_memory", {
      p_query: query,
      p_query_embedding: embedding,
      p_match_count: count,
    });
    if (error) return JsonResponse(500, { error: error.message });
    return JsonResponse(200, { mode: "hybrid", results: data ?? [] });
  } catch (err) {
    return JsonResponse(500, { error: err instanceof Error ? err.message : String(err) });
  }
});
