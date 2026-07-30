import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Buzzkill Support",
  description: "Help with setting up Buzzkill on iPhone.",
};

export default function SupportPage() {
  return (
    <main className="min-h-screen bg-neutral-950 px-6 py-16 text-neutral-100 sm:px-10">
      <article className="mx-auto max-w-3xl space-y-8 leading-8 text-neutral-300">
        <header>
          <p className="text-sm uppercase tracking-[0.3em] text-neutral-500">Buzzkill</p>
          <h1 className="mt-3 text-4xl font-black tracking-tight text-white">Support</h1>
        </header>
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-white">Having trouble with setup?</h2>
          <p>Buzzkill guides a local Apple Shortcuts setup. Install both bundled shortcuts, enable Color Filters → Grayscale in Settings, then create one Personal Automation for when your chosen apps open and one for when they close.</p>
          <p>For help, use the setup checklist below and include your iOS version when contacting the developer through the channel associated with your App Store purchase. Please do not include private data or screenshots containing personal information.</p>
        </section>
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-white">Privacy</h2>
          <p>Buzzkill has no account, analytics, ads, or remote data collection. Read the <a className="underline" href="/privacy">privacy policy</a>.</p>
        </section>
      </article>
    </main>
  );
}
