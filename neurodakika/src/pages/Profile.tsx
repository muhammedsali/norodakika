import { useEffect, useMemo, useState } from "react";
import {
  PolarAngleAxis,
  PolarGrid,
  PolarRadiusAxis,
  Radar,
  RadarChart,
  ResponsiveContainer,
  Tooltip,
} from "recharts";
import { onAuthStateChanged, signInWithPopup, signOut, type User } from "firebase/auth";
import { auth, googleProvider, isFirebaseReady } from "../firebase/config";
import { games } from "../data/games";

const Profile = () => {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    if (!auth) {
      setUser(null);
      return;
    }
    const unsubscribe = onAuthStateChanged(auth, (nextUser) => setUser(nextUser));
    return () => unsubscribe();
  }, []);

  const performanceData = useMemo(
    () => [
      { area: "Refleks", score: 82 },
      { area: "Hafıza", score: 74 },
      { area: "Dikkat", score: 68 },
      { area: "Planlama", score: 63 },
      { area: "Görsel Algı", score: 77 },
      { area: "Sayısal Zeka", score: 70 },
      { area: "Hız", score: 80 },
    ],
    []
  );

  const recentSessions = useMemo(
    () =>
      games.slice(0, 4).map((game) => ({
        id: game.id,
        title: game.title,
        category: game.category,
        score: Math.round(60 + Math.random() * 40),
      })),
    []
  );

  const handleGoogleLogin = async () => {
    try {
      if (!auth || !googleProvider) {
        console.warn("Firebase yapılandırması eksik, giriş yapılamıyor.");
        return;
      }
      await signInWithPopup(auth, googleProvider);
    } catch (error) {
      console.error("Google login failed", error);
    }
  };

  const handleLogout = async () => {
    if (!auth) {
      return;
    }
    await signOut(auth);
  };

  return (
    <div className="flex flex-1 flex-col gap-6 px-4 pb-6 pt-6">
      <header className="flex flex-col gap-2">
        <p className="text-sm uppercase tracking-[0.3em] text-white/50">
          Profil Özeti
        </p>
        <h1 className="text-2xl font-semibold text-white">Kognitif Ölçümler</h1>
        <p className="text-sm text-white/60">
          Başarımlarını takip et ve gelişim eğrini incele.
        </p>
      </header>

      <section className="glass-panel flex flex-col gap-4 px-5 py-5">
        <div className="flex items-center gap-4">
          <div className="size-12 rounded-full border border-white/10 bg-white/10">
            {user ? (
              <img
                src={user.photoURL ?? undefined}
                alt={user.displayName ?? "Profil"}
                className="size-full rounded-full object-cover"
              />
            ) : null}
          </div>
          <div className="flex-1">
            <p className="text-xs uppercase tracking-[0.3em] text-white/50">
              Kullanıcı
            </p>
            <h2 className="text-lg font-semibold text-white">
              {user?.displayName ?? "Misafir Oyuncu"}
            </h2>
            <p className="text-sm text-white/60">
              {user?.email ?? "Performansını kaydetmek için giriş yap."}
            </p>
          </div>
          {isFirebaseReady && user ? (
            <button
              type="button"
              onClick={handleLogout}
              className="rounded-full border border-white/20 px-4 py-2 text-sm font-medium text-white/80 transition hover:border-primary/60 hover:text-white"
            >
              Çıkış
            </button>
          ) : isFirebaseReady ? (
            <button
              type="button"
              onClick={handleGoogleLogin}
              className="flex items-center gap-2 rounded-full border border-white/20 px-4 py-2 text-sm font-medium text-white/80 transition hover:border-primary/60 hover:text-white"
            >
              <span className="material-symbols-outlined text-base">login</span>
              Google ile Giriş Yap
            </button>
          ) : (
            <span className="rounded-full border border-white/10 px-4 py-2 text-xs font-medium text-white/60">
              Firebase yapılandırılınca giriş açılacak
            </span>
          )}
        </div>
      </section>

      <section className="glass-panel px-5 py-5">
        <div className="flex items-center justify-between pb-4">
          <h3 className="text-lg font-semibold text-white">Bilişsel Radar</h3>
          <span className="text-xs uppercase tracking-[0.3em] text-white/50">
            Son 14 Gün
          </span>
        </div>
        <div className="h-72">
          <ResponsiveContainer width="100%" height="100%">
            <RadarChart outerRadius="70%" data={performanceData}>
              <PolarGrid stroke="rgba(255,255,255,.1)" />
              <PolarAngleAxis dataKey="area" tick={{ fill: "#d9d2ff", fontSize: 11 }} />
              <PolarRadiusAxis
                angle={45}
                domain={[0, 100]}
                tick={{ fill: "rgba(255,255,255,.4)", fontSize: 10 }}
                stroke="rgba(255,255,255,.1)"
              />
              <Tooltip
                labelStyle={{ color: "#0f0516" }}
                contentStyle={{
                  background: "rgba(255,255,255,0.9)",
                  borderRadius: "12px",
                  border: "none",
                  color: "#0f0516",
                }}
              />
              <Radar
                dataKey="score"
                stroke="#7f0df2"
                fill="rgba(127, 13, 242, 0.35)"
                strokeWidth={2}
              />
            </RadarChart>
          </ResponsiveContainer>
        </div>
      </section>

      <section className="glass-panel px-5 py-5">
        <div className="flex items-center justify-between pb-4">
          <h3 className="text-lg font-semibold text-white">Son Seanslar</h3>
          <button
            type="button"
            className="text-xs font-medium uppercase tracking-[0.3em] text-primary"
          >
            Tümünü Gör
          </button>
        </div>
        <div className="flex flex-col gap-3">
          {recentSessions.map((session) => (
            <div
              key={session.id}
              className="flex items-center justify-between rounded-2xl border border-white/10 bg-white/5 px-4 py-3"
            >
              <div>
                <p className="text-sm font-medium text-white">{session.title}</p>
                <p className="text-xs text-white/50">Skor: {session.score}</p>
              </div>
              <span className="text-xs uppercase tracking-[0.3em] text-white/40">
                {session.category}
              </span>
            </div>
          ))}
        </div>
      </section>
    </div>
  );
};

export default Profile;

