import { createServerFn } from "@tanstack/react-start";

const GATEWAY_URL = "https://connector-gateway.lovable.dev/github";
const REPO = "Pitagorome/Pitagorome";

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

async function gh<T>(path: string, lovableKey: string, ghKey: string): Promise<T> {
  const res = await fetch(`${GATEWAY_URL}/${path}`, {
    headers: {
      Accept: "application/vnd.github+json",
      Authorization: `Bearer ${lovableKey}`,
      "X-Connection-Api-Key": ghKey,
    },
  });
  if (!res.ok) {
    const body = await res.text();
    console.error(`GitHub gateway request failed [${res.status}]: ${body}`);
    throw new Error(`GitHub request failed [${res.status}]`);
  }
  return (await res.json()) as T;
}

/** Public read of the game's repository: latest commits and repo stats. */
export const getRepoActivity = createServerFn({ method: "GET" })
  .inputValidator((input: { limit?: number }) => ({
    limit: Math.min(Math.max(Math.floor(Number(input?.limit) || 6), 1), 30),
  }))
  .handler(async ({ data }): Promise<RepoActivity> => {
    const lovableKey = process.env["LOVABLE_API_KEY"];
    const ghKey = process.env["GITHUB_API_KEY"];
    if (!lovableKey || !ghKey) {
      return { repo: null, commits: [], error: "Conexão com o GitHub não configurada." };
    }
    try {
      const [repo, commits] = await Promise.all([
        gh<{ stargazers_count: number; forks_count: number; pushed_at: string; html_url: string }>(
          `repos/${REPO}`,
          lovableKey,
          ghKey,
        ),
        gh<GhCommit[]>(`repos/${REPO}/commits?per_page=${data.limit}`, lovableKey, ghKey),
      ]);
      return {
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
    } catch (err) {
      console.error(err);
      return { repo: null, commits: [], error: "Não foi possível carregar as novidades agora." };
    }
  });
