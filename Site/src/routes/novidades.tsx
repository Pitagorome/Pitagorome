import { createFileRoute, useRouter } from "@tanstack/react-router";
import { GitFork, Github, Star } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PageHero } from "@/components/site/PageHero";
import { CommitList } from "@/components/site/CommitList";
import { Prop } from "@/components/site/Pixel";
import { getRepoActivity } from "@/lib/github.functions";
import { formatDate } from "@/lib/github-format";
import { REPO_URL } from "@/lib/game-content";

export const Route = createFileRoute("/novidades")({
  head: () => ({
    meta: [
      { title: "Novidades · Pitagorome" },
      { name: "description", content: "Diário de desenvolvimento do Pitagorome com as últimas mudanças do repositório no GitHub." },
      { property: "og:title", content: "Novidades do Pitagorome" },
      { property: "og:description", content: "Acompanhe o desenvolvimento do jogo, atualização por atualização." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  loader: () => getRepoActivity({ data: { limit: 20 } }),
  staleTime: 5 * 60_000,
  component: NewsPage,
  errorComponent: NewsError,
  notFoundComponent: () => <p className="p-10 text-center">Nada por aqui.</p>,
});

function NewsError() {
  const router = useRouter();
  return (
    <div className="mx-auto max-w-xl px-6 py-40 text-center">
      <p className="panel p-6">Não foi possível carregar as novidades.</p>
      <Button variant="game" className="mt-6" onClick={() => router.invalidate()}>
        Tentar de novo
      </Button>
    </div>
  );
}

function NewsPage() {
  const data = Route.useLoaderData();
  return (
    <>
      <PageHero eyebrow="Diário de desenvolvimento" title="Novidades da escola">
        Tudo o que a equipe mudou recentemente, puxado ao vivo do repositório no GitHub.
      </PageHero>
      <section className="mx-auto grid max-w-6xl gap-10 px-6 py-24 lg:grid-cols-[1fr_2fr]">
        <aside className="space-y-6">
          <div className="panel p-6">
            <Prop name="muralBoard" scale={5} />
            <h2 className="mt-4 text-2xl text-card-foreground">Quadro de avisos</h2>
            {data.repo ? (
              <dl className="mt-4 space-y-2 text-sm">
                <div className="flex items-center justify-between">
                  <dt className="flex items-center gap-2 text-muted-foreground"><Star className="h-4 w-4" /> Estrelas</dt>
                  <dd className="font-bold">{data.repo.stars}</dd>
                </div>
                <div className="flex items-center justify-between">
                  <dt className="flex items-center gap-2 text-muted-foreground"><GitFork className="h-4 w-4" /> Forks</dt>
                  <dd className="font-bold">{data.repo.forks}</dd>
                </div>
                <div className="flex items-center justify-between">
                  <dt className="text-muted-foreground">Última atualização</dt>
                  <dd className="font-bold">{formatDate(data.repo.pushedAt)}</dd>
                </div>
              </dl>
            ) : (
              <p className="mt-3 text-sm text-muted-foreground">{data.error}</p>
            )}
            <Button asChild variant="panel" className="mt-6 w-full">
              <a href={REPO_URL} target="_blank" rel="noreferrer">
                <Github /> Abrir repositório
              </a>
            </Button>
          </div>
        </aside>
        <div>
          {data.commits.length > 0 ? (
            <CommitList commits={data.commits} />
          ) : (
            <p className="panel p-6 text-muted-foreground">{data.error ?? "Nenhuma novidade ainda."}</p>
          )}
        </div>
      </section>
    </>
  );
}
