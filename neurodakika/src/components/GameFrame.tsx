import { AnimatePresence, motion } from "framer-motion";
import type { Game } from "../data/games";

interface GameFrameProps {
  game: Game | null;
  onClose: () => void;
}

const GameFrame = ({ game, onClose }: GameFrameProps) => {
  return (
    <AnimatePresence>
      {game && (
        <motion.div
          key={game.id}
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-lg"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <motion.div
            className="relative h-[90vh] w-[90vw] max-w-5xl overflow-hidden rounded-3xl border border-white/10 bg-background-dark"
            initial={{ scale: 0.95, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            exit={{ scale: 0.95, opacity: 0 }}
            transition={{ type: "spring", stiffness: 220, damping: 22 }}
          >
            <header className="flex items-center justify-between border-b border-white/10 px-6 py-4">
              <div>
                <p className="text-xs uppercase tracking-[0.35em] text-white/50">
                  {game.category}
                </p>
                <h2 className="text-xl font-semibold text-white">{game.title}</h2>
              </div>
              <button
                onClick={onClose}
                className="rounded-full border border-white/10 px-4 py-2 text-sm font-medium text-white/70 transition-colors hover:border-primary/60 hover:text-white"
              >
                Kapat
              </button>
            </header>
            <iframe
              title={game.title}
              src={game.iframeUrl}
              className="h-[calc(90vh-80px)] w-full border-0"
              allowFullScreen
            />
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
};

export default GameFrame;

