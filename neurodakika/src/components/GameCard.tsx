import { motion } from "framer-motion";
import type { Game } from "../data/games";

interface GameCardProps {
  game: Game;
  onPlay: (game: Game) => void;
}

const GameCard = ({ game, onPlay }: GameCardProps) => {
  return (
    <motion.button
      type="button"
      onClick={() => onPlay(game)}
      whileHover={{ y: -4 }}
      whileTap={{ scale: 0.97 }}
      className="flex flex-col gap-4 rounded-3xl bg-white/5 p-5 text-left transition-all duration-200 hover:bg-white/10 hover:shadow-glow focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary"
    >
      <div className="flex aspect-square w-full items-center justify-center rounded-2xl bg-primary/20 text-primary">
        <span className="material-symbols-outlined text-4xl">{game.icon}</span>
      </div>
      <div className="flex flex-col gap-1">
        <p className="text-sm font-medium uppercase tracking-[0.2em] text-white/60">
          {game.category}
        </p>
        <h3 className="text-lg font-semibold text-white">{game.title}</h3>
        <p className="text-sm text-white/60">{game.description}</p>
      </div>
      <div className="mt-auto flex items-center gap-2 text-sm font-semibold text-primary">
        Başlat
        <span className="material-symbols-outlined text-base leading-none">play_arrow</span>
      </div>
    </motion.button>
  );
};

export default GameCard;

