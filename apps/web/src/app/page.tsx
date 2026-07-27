const platformCards = [
  {
    title: "Android: real grayscale overlay spike",
    body: "Uses local app selection, Accessibility events, and a draw-over-apps overlay. No backend or paid API required.",
  },
  {
    title: "iOS: local grayscale automation",
    body: "Choose apps, then create one local Apple Shortcuts automation that turns the system Color Filter on when they open and off when they close.",
  },
  {
    title: "Local first",
    body: "Selections, bypass timers, and demo state are stored on-device so the app stays testable before any external services exist.",
  },
];

const steps = [
  "Pick the apps that usually pull you in.",
  "On iOS, Apple Shortcuts toggles the system Grayscale Color Filter.",
  "Selected apps remain fully usable; Buzzkill never blocks or time-limits them.",
  "When the selected app closes, the same automation restores color.",
];

const settings = ["Protected apps", "Focus intensity", "Quiet hours", "Bypass length"];

const optionalFeatures = [
  {
    title: "Speed Bumps",
    body: "An optional escalating friction ladder: a small pause first, then stronger prompts when you keep coming back.",
  },
  {
    title: "Better Moves",
    body: "An optional replacement prompt: “What would you rather do right now?” Move, read, text someone, work, handle life admin, or calm down.",
  },
];

function LogoMark({ className = "" }: { className?: string }) {
  return (
    <span
      aria-label="Buzzkill logo"
      className={`relative grid place-items-center rounded-[1.15rem] border border-white/25 bg-white text-neutral-950 shadow-[0_0_40px_rgba(255,255,255,0.12)] ${className}`}
    >
      <span className="text-lg font-black tracking-[-0.14em]">B</span>
      <span className="absolute bottom-2 h-[2px] w-5 rounded-full bg-neutral-950" />
    </span>
  );
}

export default function Home() {
  return (
    <main className="min-h-screen overflow-hidden bg-neutral-950 text-neutral-50">
      <section className="relative mx-auto flex min-h-screen w-full max-w-6xl flex-col px-6 py-8 sm:px-10 lg:px-12">
        <div className="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top_left,_rgba(255,255,255,0.20),_transparent_34%),linear-gradient(135deg,_#0a0a0a,_#3f3f46_45%,_#111827)] grayscale" />
        <nav className="flex items-center justify-between text-sm text-neutral-300">
          <div className="flex items-center gap-3">
            <LogoMark className="h-9 w-9" />
            <span className="font-semibold tracking-wide">Buzzkill</span>
          </div>
          <span className="rounded-full border border-white/15 px-3 py-1 text-xs uppercase tracking-[0.25em] text-neutral-300">
            local-first spike
          </span>
        </nav>

        <div className="grid flex-1 items-center gap-12 py-16 lg:grid-cols-[1.05fr_0.95fr]">
          <div>
            <p className="mb-5 inline-flex rounded-full border border-white/15 bg-white/10 px-4 py-2 text-sm text-neutral-200 shadow-2xl backdrop-blur">
              Minimal settings for making addictive apps boring.
            </p>
            <h1 className="max-w-4xl text-5xl font-black leading-[0.95] tracking-[-0.06em] sm:text-7xl lg:text-8xl">
              Turn the feed gray before it hooks you.
            </h1>
            <p className="mt-7 max-w-2xl text-lg leading-8 text-neutral-300 sm:text-xl">
              Buzzkill is a tiny control panel: choose apps, configure Grayscale once, and let one local Apple Shortcuts automation turn the display black and white while those apps are open.
            </p>
            <div className="mt-9 flex flex-col gap-3 sm:flex-row">
              <a
                className="rounded-full border border-neutral-950/20 bg-white px-6 py-3 text-center font-bold text-neutral-950 shadow-[0_12px_32px_rgba(0,0,0,0.35)] transition hover:bg-neutral-200"
                href="#demo"
              >
                View the flow
              </a>
              <a
                className="rounded-full border border-white/20 px-6 py-3 text-center font-bold text-white transition hover:bg-white/10"
                href="#platforms"
              >
                Platform plan
              </a>
            </div>
          </div>

          <div id="demo" className="mx-auto w-full max-w-sm rounded-[2.5rem] border border-white/20 bg-neutral-900/80 p-4 shadow-2xl backdrop-blur">
            <div className="rounded-[2rem] bg-neutral-100 p-4 text-neutral-950 grayscale">
              <div className="mb-4 flex items-center justify-between text-xs text-neutral-500">
                <span>9:41</span>
                <LogoMark className="h-8 w-8 border-neutral-950/15" />
              </div>
              <div className="mb-4 rounded-3xl border border-neutral-300 bg-white p-4">
                <p className="text-[10px] font-bold uppercase tracking-[0.32em] text-neutral-500">Settings</p>
                <h2 className="mt-1 text-2xl font-black tracking-[-0.08em]">Make it dull.</h2>
                <div className="mt-4 grid grid-cols-2 gap-2">
                  {settings.map((item) => (
                    <span key={item} className="rounded-2xl bg-neutral-100 px-3 py-2 text-xs font-bold text-neutral-700">
                      {item}
                    </span>
                  ))}
                </div>
              </div>
              <div className="space-y-3">
                <div className="h-28 rounded-3xl bg-gradient-to-br from-pink-400 via-orange-300 to-purple-500" />
                <div className="h-4 w-3/4 rounded-full bg-neutral-300" />
                <div className="h-4 w-1/2 rounded-full bg-neutral-300" />
              </div>
              <div className="mt-5 rounded-3xl bg-neutral-950 p-5 text-white shadow-xl">
                <p className="text-xs uppercase tracking-[0.25em] text-neutral-400">Buzzkill active</p>
                <h2 className="mt-2 text-2xl font-black tracking-tight">Pause before scrolling</h2>
                <p className="mt-2 text-sm leading-6 text-neutral-300">
                  This app is protected. What would you rather do right now?
                </p>
                <button className="mt-4 w-full rounded-full bg-white px-4 py-3 text-sm font-bold text-neutral-950">
                  Bypass 10 min
                </button>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section id="platforms" className="border-t border-white/10 bg-neutral-900 px-6 py-16 sm:px-10 lg:px-12">
        <div className="mx-auto max-w-6xl">
          <div className="grid gap-5 md:grid-cols-3">
            {platformCards.map((card) => (
              <article key={card.title} className="rounded-3xl border border-white/10 bg-white/[0.04] p-6">
                <h2 className="text-xl font-bold tracking-tight">{card.title}</h2>
                <p className="mt-3 leading-7 text-neutral-300">{card.body}</p>
              </article>
            ))}
          </div>

          <div className="mt-12 grid gap-8 lg:grid-cols-[0.8fr_1.2fr]">
            <div>
              <p className="text-sm uppercase tracking-[0.3em] text-neutral-500">Flow</p>
              <h2 className="mt-3 text-3xl font-black tracking-tight sm:text-4xl">Works without APIs first.</h2>
            </div>
            <ol className="grid gap-3 sm:grid-cols-2">
              {steps.map((step, index) => (
                <li key={step} className="rounded-3xl bg-neutral-950 p-5 text-neutral-200">
                  <span className="text-sm font-black text-neutral-500">0{index + 1}</span>
                  <p className="mt-3 font-semibold">{step}</p>
                </li>
              ))}
            </ol>
          </div>

          <div className="mt-12 grid gap-5 md:grid-cols-2">
            {optionalFeatures.map((feature) => (
              <article key={feature.title} className="rounded-3xl border border-white/10 bg-neutral-950 p-6">
                <p className="text-xs font-bold uppercase tracking-[0.25em] text-neutral-500">Optional</p>
                <h2 className="mt-3 text-2xl font-black tracking-tight">{feature.title}</h2>
                <p className="mt-3 leading-7 text-neutral-300">{feature.body}</p>
                <p className="mt-4 text-sm font-semibold text-neutral-400">Independent on/off toggle. Local-first.</p>
              </article>
            ))}
          </div>
        </div>
      </section>
    </main>
  );
}
