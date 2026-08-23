import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';

import { JSDOM } from 'jsdom';

const root = process.cwd();
const sourceDirectories = process.argv.length > 2 ? process.argv.slice(2) : ['_posts', '_courses'];
const fencePattern = /^```mermaid\s*\r?\n([\s\S]*?)^```\s*$/gm;
const frontMatterPattern = /^---\s*\r?\n([\s\S]*?)^---\s*$/m;

function markdownFiles(directory) {
  const entries = fs.readdirSync(directory, { withFileTypes: true });
  return entries.flatMap((entry) => {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) return markdownFiles(entryPath);
    return entry.isFile() && entry.name.endsWith('.md') ? [entryPath] : [];
  });
}

const dom = new JSDOM('<!doctype html><html><body></body></html>');
const browserGlobals = {
  window: dom.window,
  document: dom.window.document,
  navigator: dom.window.navigator,
  Element: dom.window.Element,
  HTMLElement: dom.window.HTMLElement,
  SVGElement: dom.window.SVGElement,
  Node: dom.window.Node
};

Object.entries(browserGlobals).forEach(([name, value]) => {
  Object.defineProperty(globalThis, name, { configurable: true, value });
});

const { default: mermaid } = await import('mermaid');
mermaid.initialize({ startOnLoad: false, securityLevel: 'strict' });

const failures = [];
let diagramCount = 0;
let fileCount = 0;

for (const sourceDirectory of sourceDirectories) {
  const absoluteDirectory = path.resolve(root, sourceDirectory);
  if (!fs.existsSync(absoluteDirectory)) {
    failures.push(`${sourceDirectory}: directory does not exist`);
    continue;
  }

  for (const filePath of markdownFiles(absoluteDirectory).sort()) {
    const source = fs.readFileSync(filePath, 'utf8');
    const diagrams = [...source.matchAll(fencePattern)];
    if (diagrams.length === 0) continue;

    fileCount += 1;
    const frontMatter = source.match(frontMatterPattern)?.[1] || '';
    if (!/^mermaid:\s*true\s*$/m.test(frontMatter)) {
      const relativePath = path.relative(root, filePath).replaceAll('\\', '/');
      failures.push(`${relativePath}: Mermaid diagrams require 'mermaid: true' in front matter`);
    }
    for (const [index, match] of diagrams.entries()) {
      diagramCount += 1;
      const line = source.slice(0, match.index).split(/\r?\n/).length;
      try {
        await mermaid.parse(match[1]);
      } catch (error) {
        const relativePath = path.relative(root, filePath).replaceAll('\\', '/');
        const message = error instanceof Error ? error.message : String(error);
        failures.push(`${relativePath}:${line} Mermaid block ${index + 1}\n${message}`);
      }
    }
  }
}

if (failures.length > 0) {
  console.error(`Mermaid validation failed: ${failures.length} of ${diagramCount} diagrams are invalid.`);
  console.error(failures.join('\n\n'));
  process.exitCode = 1;
} else {
  console.log(`Mermaid validation passed: ${diagramCount} diagrams in ${fileCount} Markdown files.`);
}