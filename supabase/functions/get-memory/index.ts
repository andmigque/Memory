//// # get-memory Edge Function
//// User-facing direct retrieval for Memory. Runs as the caller: it forwards the caller's user JWT to
//// PostgREST, so get_memory executes under that user's RLS. No secret key. verify_jwt is off; the
//// caller's JWT and RLS are the gate, so an anon caller is denied at the table grant.
//// Request: { entity?, limit? }. Mirrors the get_memory RPC: omit entity for every entity, omit limit for 10.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

function JsonResponse(status: number, body: object): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
  });
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

    // Mirror the get_memory RPC defaults: null entity => every entity, limit => 10.
    const body = await req.json().catch(() => ({}));
    const entity = typeof body.entity === "string" && body.entity !== "" ? body.entity : null;
    const limit = typeof body.limit === "number" ? body.limit : 10;

    const { data, error } = await supabase.rpc("get_memory", {
      p_entity: entity,
      p_limit: limit,
    });
    if (error) return JsonResponse(500, { error: error.message });
    return JsonResponse(200, { results: data ?? [] });
  } catch (err) {
    return JsonResponse(500, { error: err instanceof Error ? err.message : String(err) });
  }
});
