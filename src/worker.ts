const BASE =
  "https://raw.githubusercontent.com/dhruv-anand-aintech/mobile-agent-termux-workarounds/main/scripts/termux";

const LINKS: Record<string, string> = {
  "/": `${BASE}/install-all-agents.sh`,
  "/all": `${BASE}/install-all-agents.sh`,
  "/codex": `${BASE}/install-codex.sh`,
  "/opencode": `${BASE}/install-opencode.sh`,
  "/cursor": `${BASE}/install-cursor-agent.sh`,
  "/cursor-agent": `${BASE}/install-cursor-agent.sh`,
};

export default {
  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url);
    const target = LINKS[url.pathname.replace(/\/$/, "") || "/"];

    if (!target) {
      return new Response("Not found\n", {
        status: 404,
        headers: { "content-type": "text/plain; charset=utf-8" },
      });
    }

    if (request.method === "HEAD") {
      return new Response(null, {
        status: 302,
        headers: { location: target, "cache-control": "public, max-age=300" },
      });
    }

    return Response.redirect(target, 302);
  },
};
