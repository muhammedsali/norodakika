export type CognitiveCategory =
  | "Refleks"
  | "Hafıza"
  | "Dikkat"
  | "Sayısal Zeka"
  | "Planlama"
  | "Görsel Algı"
  | "Hız";

export interface Game {
  id: string;
  title: string;
  category: CognitiveCategory;
  description: string;
  iframeUrl: string;
  icon: string;
}

export const games: Game[] = [
  {
    id: "REF01",
    title: "Reflex Tap",
    category: "Refleks",
    description: "Reflekslerini test et",
    iframeUrl: "/games/reflex-tap/index.html",
    icon: "touch_app",
  },
  {
    id: "MEM01",
    title: "N-Back Mini",
    category: "Hafıza",
    description: "Hafızanı güçlendir",
    iframeUrl: "/games/nback-mini/index.html",
    icon: "memory",
  },
  {
    id: "ATT01",
    title: "Stroop Tap",
    category: "Dikkat",
    description: "Odaklanma becerisi",
    iframeUrl: "/games/stroop-tap/index.html",
    icon: "palette",
  },
  {
    id: "CAL01",
    title: "Hızlı Matematik",
    category: "Sayısal Zeka",
    description: "Sayısal zekanı hızlandır",
    iframeUrl: "/games/hizli-matematik/index.html",
    icon: "calculate",
  },
  {
    id: "SPD01",
    title: "Speed Trail",
    category: "Hız",
    description: "Tepki hızını geliştir",
    iframeUrl: "/games/reflex-tap/index.html",
    icon: "bolt",
  },
  {
    id: "MEM02",
    title: "Sequence Echo",
    category: "Hafıza",
    description: "Sayı dizilerini takip et",
    iframeUrl: "/games/nback-mini/index.html",
    icon: "extension",
  },
  {
    id: "VIS01",
    title: "Visual Span",
    category: "Görsel Algı",
    description: "Görsel desenleri analiz et",
    iframeUrl: "/games/stroop-tap/index.html",
    icon: "visibility",
  },
  {
    id: "PLA01",
    title: "Path Planner",
    category: "Planlama",
    description: "Adım adım strateji üret",
    iframeUrl: "/games/hizli-matematik/index.html",
    icon: "route",
  },
  {
    id: "ATT02",
    title: "Focus Shift",
    category: "Dikkat",
    description: "Çoklu uyaranlar arasında geçiş yap",
    iframeUrl: "/games/stroop-tap/index.html",
    icon: "filter_alt",
  },
  {
    id: "SPD02",
    title: "Quick Mirror",
    category: "Hız",
    description: "Simetriye hızlı tepki ver",
    iframeUrl: "/games/reflex-tap/index.html",
    icon: "symptoms",
  },
];

