import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Buzzkill Privacy Policy",
  description: "How Buzzkill handles information on iPhone.",
};

export default function PrivacyPage() {
  return (
    <main className="min-h-screen bg-neutral-950 px-6 py-16 text-neutral-100 sm:px-10">
      <article className="mx-auto max-w-3xl space-y-8 leading-8 text-neutral-300">
        <header>
          <p className="text-sm uppercase tracking-[0.3em] text-neutral-500">Buzzkill</p>
          <h1 className="mt-3 text-4xl font-black tracking-tight text-white">Privacy Policy</h1>
          <p className="mt-3 text-sm text-neutral-500">Last updated: July 30, 2026</p>
        </header>
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-white">Summary</h2>
          <p>Buzzkill does not collect, transmit, store on a remote server, or share personal data. Your setup stays on your iPhone.</p>
          <p>Buzzkill stores only local setup status, such as whether its bundled shortcuts were opened and whether setup was completed. This is stored in the iOS app container and is never uploaded.</p>
        </section>
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-white">What Buzzkill does not do</h2>
          <p>Buzzkill has no account, advertising, analytics, crash reporting, tracking, cloud storage, app-usage history, screen-content access, location, microphone, camera, or contacts access. It does not block apps or impose time limits.</p>
        </section>
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-white">System information</h2>
          <p>Buzzkill reads the iPhone’s Color Filters status so it can explain whether grayscale is enabled. Apple Shortcuts performs the local automation; Buzzkill cannot directly change that protected setting.</p>
        </section>
        <section className="space-y-4">
          <h2 className="text-2xl font-bold text-white">Contact</h2>
          <p>For privacy questions or support, use the public <a className="underline" href="/support">Buzzkill support page</a>.</p>
        </section>
      </article>
    </main>
  );
}
