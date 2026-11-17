import { createServerFn } from "@tanstack/react-start";

// Public GitHub REST API: the repository is public, so no key is needed.
// Without a token GitHub allows 60 requests per hour per IP, so results are cached below.
// Set GITHUB_TOKEN (optional) to raise that limit.
const API_URL = "https://api.github.com";
const REPO = "Pitagorome/Pitagorome";
const CACHE_MS = 5 * 60_000;

export type RepoCommit = {
  sha: string;
  message: string;
  author: string;
  login: string | null;
  avatar: string | null;
  date: string;
  url: string;
};

export type RepoActivity = {
  repo: { stars: number; forks: number; pushedAt: string; url: string } | null;
  commits: RepoCommit[];
  error: string | null;
};

type GhCommit = {
  sha: string;
  html_url: string;
  commit: { message: string; author: { name: string; date: string } | null };
  author: { login: string; avatar_url: string } | null;
};

async function gh<T>(path: string): Promise<T> {
  const headers: Record<string, string> = {
    Accept: "application/vnd.github+json",
    "User-Agent": "pitagorome-site",
  };
  const token = process.env["GITHUB_TOKEN"];
  if (token) headers["Authorization"] = `Bearer ${token}`;

  const res = await fetch(`${API_URL}/${path}`, { headers });
  if (!res.ok) {
    const body = await res.text();
    console.error(`GitHub request failed [${res.status}]: ${body}`);
    throw new Error(`GitHub request failed [${res.status}]`);
  }
  return (await res.json()) as T;
}

// Last good answer per limit, shared by every visitor of this server.
const cache = new Map<number, { at: number; value: RepoActivity }>();

/** Public read of the game's repository: latest commits and repo stats. */
export const getRepoActivity = createServerFn({ method: "GET" })
  .inputValidator((input: { limit?: number }) => ({
    limit: Math.min(Math.max(Math.floor(Number(input?.limit) || 6), 1), 30),
  }))
  .handler(async ({ data }): Promise<RepoActivity> => {
    const cached = cache.get(data.limit);
    if (cached && Date.now() - cached.at < CACHE_MS) return cached.value;
    try {
      const [repo, commits] = await Promise.all([
        gh<{ stargazers_count: number; forks_count: number; pushed_at: string; html_url: string }>(
          `repos/${REPO}`,
        ),
        gh<GhCommit[]>(`repos/${REPO}/commits?per_page=${data.limit}`),
      ]);
      const value: RepoActivity = {
        repo: {
          stars: repo.stargazers_count,
          forks: repo.forks_count,
          pushedAt: repo.pushed_at,
          url: repo.html_url,
        },
        commits: commits.map((c) => ({
          sha: c.sha.slice(0, 7),
          message: c.commit.message.split("\n")[0] ?? "",
          author: c.commit.author?.name ?? c.author?.login ?? "Equipe",
          login: c.author?.login ?? null,
          avatar: c.author?.avatar_url ?? null,
          date: c.commit.author?.date ?? "",
          url: c.html_url,
        })),
        error: null,
      };
      cache.set(data.limit, { at: Date.now(), value });
      return value;
    } catch (err) {
      console.error(err);
      // If GitHub fails (e.g. hourly limit reached), keep showing the last good answer.
      if (cached) return cached.value;
      return { repo: null, commits: [], error: "Não foi possível carregar as novidades agora." };
    }
  });
