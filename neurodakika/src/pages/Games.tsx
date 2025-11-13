import { useMemo, useState } from "react";
import GameCard from "../components/GameCard";
import GameFrame from "../components/GameFrame";
import type { Game } from "../data/games";
import { games } from "../data/games";

const Games = () => {
  const [selectedCategory, setSelectedCategory] = useState<string>("Tümü");
  const [activeGame, setActiveGame] = useState<Game | null>(null);

  const categories = useMemo(
    () => ["Tümü", ...new Set(games.map((game) => game.category))],
    []
  );

  const filteredGames =
    selectedCategory === "Tümü"
      ? games
      : games.filter((game) => game.category === selectedCategory);

  return (
    <div className="flex flex-1 flex-col gap-6 px-4 pb-6 pt-6">
      <header className="flex flex-col gap-2">
        <p className="text-sm uppercase tracking-[0.3em] text-white/50">
          Egzersiz Alanı
        </p>
        <h1 className="text-2xl font-semibold text-white">Oyun Kütüphanesi</h1>
        <p className="text-sm text-white/60">
          Hafıza, dikkat ve refleks yeteneklerini geliştirmek için tasarlanmış oyunları keşfet.
        </p>
      </header>

      <div className="flex gap-3 overflow-x-auto">
        {categories.map((category) => {
          const isActive = category === selectedCategory;
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

      <section className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        {filteredGames.map((game) => (
          <GameCard key={game.id} game={game} onPlay={setActiveGame} />
        ))}
      </section>

      <GameFrame game={activeGame} onClose={() => setActiveGame(null)} />
    </div>
  );
};

export default Games;

