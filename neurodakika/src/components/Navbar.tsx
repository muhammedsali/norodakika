import { NavLink } from "react-router-dom";

const links = [
  { label: "Home", to: "/" },
  { label: "Games", to: "/games" },
  { label: "Profile", to: "/profile" },
];

const Navbar = () => {
  return (
    <header className="sticky top-0 z-40 border-b border-white/10 bg-background-dark/80 text-white backdrop-blur-xl">
      <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
        <div className="flex items-center gap-3">
          <div className="flex size-10 items-center justify-center rounded-full bg-primary/30 text-lg font-bold text-white">
            ND
          </div>
          <div className="flex flex-col leading-tight">
            <span className="text-sm text-white/70">Kognitif Stüdyo</span>
            <span className="text-lg font-semibold">NöroDakika</span>
          </div>
        </div>
        <nav className="hidden items-center gap-6 text-sm font-medium text-white/60 sm:flex">
          {links.map((link) => (
            <NavLink
              key={link.to}
              to={link.to}
              className={({ isActive }) =>
                `transition-colors duration-200 ${
                  isActive ? "text-white" : "hover:text-white"
                }`
              }
            >
              {link.label}
            </NavLink>
          ))}
        </nav>
      </div>
    </header>
  );
};

export default Navbar;

