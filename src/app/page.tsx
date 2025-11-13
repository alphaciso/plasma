import AIAutomation from '@/components/sections/ai-automation';
import Features from '@/components/sections/features';
import FeaturesTabsSection from '@/components/sections/features-tabs';
import Features2 from '@/components/sections/features2';
import Hero from '@/components/sections/hero';
import Testimonials from '@/components/sections/testimonials';

export default function Home() {
  return (
    <>
      <Hero />
      <Features />
      <Features2 />
      <AIAutomation />
      <FeaturesTabsSection />
      <Testimonials />
    </>
  );
}
