import { useEffect } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import BottomNav from "./components/BottomNav";
import Navbar from "./components/Navbar";
import Games from "./pages/Games";
import Home from "./pages/Home";
import Profile from "./pages/Profile";

const App = () => {
  useEffect(() => {
    document.documentElement.classList.add("dark");
  }, []);

  return (
    <div className="min-h-screen bg-background-dark text-white">
      <Navbar />
      <main className="mx-auto flex min-h-[calc(100vh-4rem)] max-w-5xl flex-col pb-28 sm:pb-12">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/games" element={<Games />} />
          <Route path="/profile" element={<Profile />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
      <BottomNav />
    </div>
  );
};

export default App;

