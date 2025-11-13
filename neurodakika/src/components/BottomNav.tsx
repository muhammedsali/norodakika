import { NavLink, useLocation } from "react-router-dom";

const items = [
  { label: "Ana Sayfa", to: "/", icon: "home" },
  { label: "Oyunlar", to: "/games", icon: "sports_esports" },
  { label: "İstatistik", to: "/profile?tab=stats", icon: "bar_chart" },
  { label: "Profil", to: "/profile", icon: "person" },
];

const BottomNav = () => {
  const location = useLocation();

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-30 border-t border-white/10 bg-background-dark/80 px-2 py-2 text-xs text-white/70 backdrop-blur-xl sm:hidden">
      <div className="mx-auto flex max-w-md justify-around">
        {items.map((item) => {
          const isActive =
            item.to === "/profile?tab=stats"
              ? location.pathname === "/profile" && location.search.includes("tab=stats")
              : location.pathname === item.to;
          return (
            <NavLink
              key={item.to}
              to={item.to}
              className={({ isActive: routeActive }) =>
                `flex flex-col items-center gap-1 transition-colors ${
                  isActive || routeActive ? "text-primary" : "hover:text-white"
                }`
              }
            >
              <span className="material-symbols-outlined text-xl">{item.icon}</span>
              <span>{item.label}</span>
            </NavLink>
          );
        })}
      </div>
    </nav>
  );
};

export default BottomNav;

