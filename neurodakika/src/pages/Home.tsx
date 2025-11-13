import { useMemo, useState } from "react";
import { motion } from "framer-motion";
import GameCard from "../components/GameCard";
import GameFrame from "../components/GameFrame";
import type { Game } from "../data/games";
import { games } from "../data/games";

const Home = () => {
  const [selectedCategory, setSelectedCategory] = useState<string>("Tümü");
  const [activeGame, setActiveGame] = useState<Game | null>(null);

  const categories = useMemo(
    () => ["Tümü", ...new Set(games.map((game) => game.category))],
    []
  );

  const filteredGames = useMemo(() => {
    const pool =
      selectedCategory === "Tümü"
        ? games
        : games.filter((game) => game.category === selectedCategory);
    return pool.slice(0, 4);
  }, [selectedCategory]);

  return (
    <div className="flex flex-1 flex-col gap-6 pb-4">
      <section className="px-4 pt-6">
        <div className="flex items-center justify-between rounded-3xl border border-white/10 bg-gradient-to-br from-primary/30 via-primary/10 to-transparent px-5 py-4">
          <div className="flex items-center gap-4">
            <div className="size-12 rounded-full border border-white/20 bg-white/10" />
            <div>
              <p className="text-sm text-white/60">Hoş geldin,</p>
              <h1 className="text-2xl font-semibold">Elif</h1>
            </div>
          </div>
          <button className="rounded-full border border-white/20 px-4 py-2 text-sm font-medium text-white/80 transition hover:border-primary/60 hover:text-white">
            <span className="material-symbols-outlined align-middle text-base">
              settings
            </span>
          </button>
        </div>
      </section>

      <section>
        <h2 className="section-title">Kategoriler</h2>
        <div className="flex gap-3 overflow-x-auto px-4 pb-2 pt-3">
          {categories.map((category) => {
            const isActive = selectedCategory === category;
            return (
              <button
                key={category}
                type="button"
                className={`pill-button ${
                  isActive ? "pill-button-active" : "pill-button-inactive"
                }`}
                onClick={() => setSelectedCategory(category)}
              >
                {category}
              </button>
            );
          })}
        </div>
      </section>

      <section className="px-4">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          {filteredGames.map((game) => (
            <GameCard key={game.id} game={game} onPlay={setActiveGame} />
          ))}
        </div>
      </section>

      <section className="px-4">
        <motion.button
          type="button"
          whileTap={{ scale: 0.98 }}
          className="w-full rounded-3xl bg-primary py-4 text-lg font-semibold text-white shadow-glow transition hover:bg-primary/90"
          onClick={() => setActiveGame(filteredGames[0] ?? games[0])}
        >
          Başla: Günün Antrenmanı
        </motion.button>
      </section>

      <GameFrame game={activeGame} onClose={() => setActiveGame(null)} />
    </div>
  );
};

export default Home;

