//// # invoke-memory-embedding Edge Function
//// Semantic layer for Memory. Generates gte-small embeddings in the Edge Runtime and serves search, queue update, and single-row embedding actions.
////
//// Request: `POST` JSON. Supported bodies:
//// - `{ action: "search_memory", query, mode?: "hybrid" | "semantic", threshold?, count? }`
//// - `{ action: "update_memory_embedding_queue", batch? }`
//// - `{ action: "set_memory_embedding", id, sentence }`
////
//// Response: `200 { ... }` on success; `400 / 401 / 500 { error: <message> }` otherwise.
//// Auth: deployed with verify_jwt enabled, and the function additionally requires the caller's
//// `Authorization: Bearer` token to equal the project service role key. Any other valid project JWT
//// (e.g. the anon key) is rejected with 401. This is the private-function gate.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

type EmbedMemoryRequest = {
  action: string;
  query: string;
  mode: string;
  threshold: number;
  count: number;
  batch: number;
  id: number;
  sentence: string;
};

type MemoryEmbeddingRow = {
  id: number;
  sentence: string;
};

const EmptyRequest: EmbedMemoryRequest = {
  action: "",
  query: "",
  mode: "hybrid",
  threshold: 0.5,
  count: 20,
  batch: 50,
  id: 0,
  sentence: "",
};

const embeddingModel = new Supabase.ai.Session("gte-small");

Deno.serve(async (req: Request) => {
  try {
    const url = Deno.env.get("SUPABASE_URL") || "";
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") || "";

    if (url === "" || serviceRoleKey === "") {
      return JsonResponse(500, { error: "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY" });
    }

    if (!ConstantTimeEqual(BearerToken(req), serviceRoleKey)) {
      return JsonResponse(401, { error: "unauthorized" });
    }

    const supabase = createClient(url, serviceRoleKey);
    const body = await ReadBody(req);

    if (body.action === "search_memory") {
      return await SearchMemory(supabase, body);
    }

    if (body.action === "update_memory_embedding_queue") {
      return await UpdateMemoryEmbeddingQueue(supabase, body);
    }

    if (body.action === "set_memory_embedding") {
      return await SetMemoryEmbedding(supabase, body);
    }

    return JsonResponse(400, { error: `unknown action: ${body.action}` });
  } catch (err) {
    return JsonResponse(500, { error: ErrorMessage(err) });
  }
});

//// # SearchMemory
//// Embeds the incoming query and dispatches to semantic-only or hybrid RPC search.
async function SearchMemory(supabase: ReturnType<typeof createClient>, body: EmbedMemoryRequest): Promise<Response> {
  if (body.query === "") {
    return JsonResponse(400, { error: "query required" });
  }

  const embedding = JSON.stringify(await Embed(body.query));

  if (body.mode === "semantic") {
    const { data, error } = await supabase.rpc("search_memory_embedding", {
      p_query_embedding: embedding,
      p_match_threshold: body.threshold,
      p_match_count: body.count,
    });

    if (error) {
      return JsonResponse(500, { error: error.message });
    }

    return JsonResponse(200, { mode: "semantic", results: data ?? [] });
  }

  const { data, error } = await supabase.rpc("search_memory", {
    p_query: body.query,
    p_query_embedding: embedding,
    p_match_count: body.count,
  });

  if (error) {
    return JsonResponse(500, { error: error.message });
  }

  return JsonResponse(200, { mode: "hybrid", results: data ?? [] });
}

//// # UpdateMemoryEmbeddingQueue
//// Embeds active memory rows whose embedding is still missing.
async function UpdateMemoryEmbeddingQueue(supabase: ReturnType<typeof createClient>, body: EmbedMemoryRequest): Promise<Response> {
  const { data: rows, error } = await supabase.rpc("get_memory_embedding_queue", {
    p_limit: body.batch,
  });

  if (error) {
    return JsonResponse(500, { error: error.message });
  }

  let processed = 0;
  for (const row of (rows ?? []) as MemoryEmbeddingRow[]) {
    const embedding = JSON.stringify(await Embed(row.sentence));
    const { error: updateError } = await supabase.rpc("set_memory_embedding", {
      p_id: row.id,
      p_embedding: embedding,
    });

    if (updateError) {
      return JsonResponse(500, { error: updateError.message, processed });
    }

    processed++;
  }

  const { count } = await supabase
    .from("memory")
    .select("id", { count: "exact", head: true })
    .eq("active", true)
    .is("embedding", null);

  return JsonResponse(200, { processed, remaining: count ?? 0 });
}

//// # SetMemoryEmbedding
//// Stores one embedding for a rendered memory sentence.
async function SetMemoryEmbedding(supabase: ReturnType<typeof createClient>, body: EmbedMemoryRequest): Promise<Response> {
  if (body.id <= 0 || body.sentence === "") {
    return JsonResponse(400, { error: "id and sentence required" });
  }

  const embedding = JSON.stringify(await Embed(body.sentence));
  const { data, error } = await supabase.rpc("set_memory_embedding", {
    p_id: body.id,
    p_embedding: embedding,
  });

  if (error) {
    return JsonResponse(500, { error: error.message });
  }

  return JsonResponse(200, { id: data });
}

//// # Embed
//// Runs gte-small with mean pooling and normalization so cosine distance is well-conditioned.
async function Embed(text: string): Promise<number[]> {
  const embedding = await embeddingModel.run(text, { mean_pool: true, normalize: true });
  return embedding as number[];
}

//// # ReadBody
//// Normalizes a JSON request body into sentinel defaults instead of nullable fields.
async function ReadBody(req: Request): Promise<EmbedMemoryRequest> {
  const rawBody = await req.json().catch(() => ({}));
  const body = IsRecord(rawBody) ? rawBody : {};

  return {
    action: ReadString(body.action, EmptyRequest.action),
    query: ReadString(body.query, EmptyRequest.query),
    mode: ReadString(body.mode, EmptyRequest.mode),
    threshold: ReadNumber(body.threshold, EmptyRequest.threshold),
    count: ReadNumber(body.count, EmptyRequest.count),
    batch: ReadNumber(body.batch, EmptyRequest.batch),
    id: ReadNumber(body.id, EmptyRequest.id),
    sentence: ReadString(body.sentence, EmptyRequest.sentence),
  };
}

function IsRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function ReadString(value: unknown, fallback: string): string {
  if (typeof value === "string") return value;
  return fallback;
}

function ReadNumber(value: unknown, fallback: number): number {
  if (typeof value === "number" && Number.isFinite(value)) return value;
  return fallback;
}

function JsonResponse(status: number, body: object): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json", "Connection": "keep-alive" },
  });
}

function ErrorMessage(err: unknown): string {
  if (err instanceof Error) return err.message;
  return String(err);
}

//// # BearerToken
//// Extracts the token from an `Authorization: Bearer <token>` header, empty string when absent.
function BearerToken(req: Request): string {
  const header = req.headers.get("Authorization") || "";
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match ? match[1] : "";
}

//// # ConstantTimeEqual
//// Length-checked, constant-time string comparison so caller-token validation does not leak the
//// service role key through response timing.
function ConstantTimeEqual(a: string, b: string): boolean {
  const encoder = new TextEncoder();
  const aBytes = encoder.encode(a);
  const bBytes = encoder.encode(b);

  if (aBytes.length !== bBytes.length) {
    return false;
  }

  let diff = 0;
  for (let i = 0; i < aBytes.length; i++) {
    diff |= aBytes[i] ^ bBytes[i];
  }
  return diff === 0;
}
