# Next.js Minimal Dark Theme Template

## Overview
A modern, minimalist Next.js frontend with pure black and white aesthetic, designed for enterprise SaaS applications.

## When to Suggest
- Building modern web applications
- Need for server-side rendering or static generation
- Enterprise/professional aesthetic requirements
- Dark mode as default preference

## Core Specifications

### Design Principles
- **Color Scheme**: Pure black and white with neutral grays
- **Typography**: Clean, sans-serif with Inter font from Google Fonts
- **Style**: Minimalist, professional enterprise SaaS aesthetic
- **Layout**: Full-width, centered content with generous spacing

### Technical Stack
- Next.js 15 with TypeScript
- Tailwind CSS (using @import "tailwindcss")
- Inter font from Google Fonts

### Color Palette
```css
/* Light mode */
--background: #ffffff;
--foreground: #171717;

/* Dark mode */
--background: #0a0a0a;
--foreground: #ededed;
```

### Design Tokens
- Primary background: `bg-neutral-900` (dark mode default)
- Text: `text-neutral-100` for primary, `text-neutral-400` for secondary
- Borders: `border-neutral-800/50` with opacity
- Backgrounds: Use `bg-neutral-900/50` with `backdrop-blur-sm` for glass effects
- Accent gradients: `bg-gradient-to-br from-black via-neutral-900 to-black`

### Component Styling

#### Cards/Panels
```css
bg-neutral-900/50 backdrop-blur-sm rounded-2xl shadow-2xl border border-neutral-800/50
/* Generous padding */
p-6 sm:p-8
```

#### Input Fields
```css
bg-neutral-800/50 border border-neutral-700/50 rounded-xl px-4 py-3
/* Focus states */
focus:border-neutral-500 focus:outline-none focus:ring-1 focus:ring-white/10
/* Smooth transitions */
transition-all duration-200
```

#### Buttons
- Primary: `bg-white text-black hover:bg-neutral-200`
- Secondary: `bg-neutral-800 hover:bg-neutral-700`
- Rounded corners: `rounded-xl`
- Disabled states with reduced opacity

#### Typography
- Headers: Use gradient text with `bg-gradient-to-r from-white to-neutral-300 bg-clip-text text-transparent`
- Body text: Clean Arial/Helvetica fallbacks with antialiasing
- Secondary text: `text-neutral-400`

### Layout Patterns
- Root layout: `min-h-screen w-full flex flex-col`
- Body classes: `font-sans antialiased bg-neutral-900 text-neutral-100`
- Centered content: `flex items-center justify-center`
- Max widths for forms: `max-w-md`

### Interactive Elements
- Smooth hover transitions
- Glass morphism effects with backdrop blur
- Subtle borders with opacity
- Focus rings with low opacity white

## Implementation Files

### globals.css
```css
@import "tailwindcss";
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap');

:root {
  --background: #0a0a0a;
  --foreground: #ededed;
}

@media (prefers-color-scheme: light) {
  :root {
    --background: #ffffff;
    --foreground: #171717;
  }
}

* {
  box-sizing: border-box;
  padding: 0;
  margin: 0;
}

html,
body {
  max-width: 100vw;
  overflow-x: hidden;
}

body {
  color: rgb(var(--foreground));
  background: rgb(var(--background));
}

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}
```

### layout.tsx
```typescript
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Your App Name",
  description: "Your app description",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.className} font-sans antialiased bg-neutral-900 text-neutral-100`}>
        {children}
      </body>
    </html>
  );
}
```

### Example Component
```typescript
export default function Card() {
  return (
    <div className="bg-neutral-900/50 backdrop-blur-sm rounded-2xl shadow-2xl border border-neutral-800/50 p-6 sm:p-8">
      <h2 className="text-2xl font-bold bg-gradient-to-r from-white to-neutral-300 bg-clip-text text-transparent mb-4">
        Card Title
      </h2>
      <p className="text-neutral-400 mb-6">
        Secondary text content goes here.
      </p>
      <button className="bg-white text-black hover:bg-neutral-200 px-6 py-3 rounded-xl font-medium transition-all duration-200">
        Primary Action
      </button>
    </div>
  );
}
```

## Key Benefits
- Clean, professional appearance
- Excellent dark mode support by default
- Performance optimized with Tailwind CSS
- Accessible color contrasts
- Modern glass morphism effects
- Consistent design system

## Customization Options
- Easily switch to light mode default
- Adjust neutral color scale
- Modify border radius tokens
- Add brand accent colors
- Customize typography scale