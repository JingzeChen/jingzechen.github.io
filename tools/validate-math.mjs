import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { pathToFileURL } from 'node:url';

import MathJax from 'mathjax';

const root = process.cwd();
const sourceDirectories =
  process.argv.length > 2 ? process.argv.slice(2) : ['_posts', '_courses'];
const frontMatterPattern = /^---\s*\r?\n([\s\S]*?)^---\s*$/m;

function markdownFiles(directory) {
  const entries = fs.readdirSync(directory, { withFileTypes: true });
  return entries.flatMap((entry) => {
    const entryPath = path.join(directory, entry.name);
    if (entry.isDirectory()) return markdownFiles(entryPath);
    return entry.isFile() && entry.name.endsWith('.md') ? [entryPath] : [];
  });
}

function maskCode(source) {
  return source
    .replace(/^(?:```|~~~)[^\r\n]*\r?\n[\s\S]*?^(?:```|~~~)\s*$/gm, (block) =>
      block.replace(/[^\r\n]/g, ' ')
    )
    .replace(/`[^`\r\n]*`/g, (code) => ' '.repeat(code.length));
}

function isEscaped(source, index) {
  let backslashes = 0;
  for (let cursor = index - 1; cursor >= 0 && source[cursor] === '\\'; cursor--) {
    backslashes += 1;
  }
  return backslashes % 2 === 1;
}

function lineNumber(source, index) {
  return source.slice(0, index).split(/\r?\n/).length;
}

function closingDelimiter(source, start, delimiter, inline) {
  for (let cursor = start; cursor < source.length; cursor++) {
    if (inline && /[\r\n]/.test(source[cursor])) return -1;
    if (source.startsWith(delimiter, cursor) && !isEscaped(source, cursor)) {
      if (inline && /\s/.test(source[cursor - 1])) continue;
      return cursor;
    }
  }
  return -1;
}

function formulasIn(source) {
  const formulas = [];
  const failures = [];

  for (let cursor = 0; cursor < source.length; cursor++) {
    let delimiter;
    let closing;
    let display;

    if (source.startsWith('$$', cursor) && !isEscaped(source, cursor)) {
      delimiter = '$$';
      closing = '$$';
      display = true;
    } else if (source.startsWith('\\[', cursor) && !isEscaped(source, cursor)) {
      delimiter = '\\[';
      closing = '\\]';
      display = true;
    } else if (source.startsWith('\\(', cursor) && !isEscaped(source, cursor)) {
      delimiter = '\\(';
      closing = '\\)';
      display = false;
    } else if (
      source[cursor] === '$' &&
      source[cursor + 1] !== '$' &&
      source[cursor + 1] !== undefined &&
      !/\s/.test(source[cursor + 1]) &&
      !isEscaped(source, cursor)
    ) {
      delimiter = '$';
      closing = '$';
      display = false;
    } else {
      continue;
    }

    const contentStart = cursor + delimiter.length;
    const contentEnd = closingDelimiter(source, contentStart, closing, !display);
    if (contentEnd === -1) {
      if (display || delimiter !== '$') {
        failures.push({
          line: lineNumber(source, cursor),
          message: `unclosed '${delimiter}' delimiter`
        });
      }
      continue;
    }

    const tex = source.slice(contentStart, contentEnd);
    formulas.push({
      display,
      line: lineNumber(source, cursor),
      tex
    });
    cursor = contentEnd + closing.length - 1;
  }

  return { failures, formulas };
}

function markdownTableLines(lines) {
  const tableLines = new Set();
  const separator =
    /^\s*\|?\s*:?-{3,}:?\s*(?:\|\s*:?-{3,}:?\s*)+\|?\s*$/;

  lines.forEach((line, index) => {
    if (!separator.test(line) || index === 0 || !lines[index - 1].includes('|')) {
      return;
    }

    tableLines.add(index - 1);
    tableLines.add(index);
    for (
      let row = index + 1;
      row < lines.length && lines[row].includes('|');
      row++
    ) {
      tableLines.add(row);
    }
  });

  return tableLines;
}

const mathJaxRoot = pathToFileURL(path.resolve(root, 'node_modules', 'mathjax')).href;
await MathJax.init({
  loader: {
    load: ['input/tex', 'output/chtml'],
    paths: { mathjax: mathJaxRoot }
  },
  tex: {
    displayMath: [
      ['$$', '$$'],
      ['\\[', '\\]']
    ],
    inlineMath: [
      ['$', '$'],
      ['\\(', '\\)']
    ],
    packages: { '[-]': ['noundefined'] },
    tags: 'ams'
  }
});

const adaptor = MathJax.startup.adaptor;
const failures = [];
let fileCount = 0;
let formulaCount = 0;

for (const sourceDirectory of sourceDirectories) {
  const absoluteDirectory = path.resolve(root, sourceDirectory);
  if (!fs.existsSync(absoluteDirectory)) {
    failures.push(`${sourceDirectory}: directory does not exist`);
    continue;
  }

  for (const filePath of markdownFiles(absoluteDirectory).sort()) {
    const source = fs.readFileSync(filePath, 'utf8');
    const frontMatterMatch = source.match(frontMatterPattern);
    const frontMatter = frontMatterMatch?.[1] || '';
    const bodyStart = frontMatterMatch?.[0].length || 0;
    const body = maskCode(source.slice(bodyStart));
    const bodyLines = body.split(/\r?\n/);
    const tableLines = markdownTableLines(bodyLines);
    const { failures: delimiterFailures, formulas } = formulasIn(body);
    if (formulas.length === 0 && delimiterFailures.length === 0) continue;

    fileCount += 1;
    formulaCount += formulas.length;
    const relativePath = path.relative(root, filePath).replaceAll('\\', '/');
    const frontMatterLines = source
      .slice(0, bodyStart)
      .split(/\r?\n/).length - 1;

    if (
      formulas.length > 0 &&
      /^type:\s*reading\s*$/m.test(frontMatter) &&
      !/^math:\s*true\s*$/m.test(frontMatter)
    ) {
      failures.push(`${relativePath}:1 Reading formulas require 'math: true'`);
    }

    delimiterFailures.forEach(({ line, message }) => {
      failures.push(`${relativePath}:${line + frontMatterLines} ${message}`);
    });

    MathJax.texReset?.();
    for (const formula of formulas) {
      if (
        formula.tex.includes('|') &&
        tableLines.has(formula.line - 1)
      ) {
        failures.push(
          `${relativePath}:${formula.line + frontMatterLines} use TeX vertical-bar commands inside Markdown tables`
        );
        continue;
      }

      try {
        const node = await MathJax.tex2chtmlPromise(formula.tex, {
          display: formula.display
        });
        const errors = adaptor.tags(node, 'mjx-merror');
        errors.forEach((error) => {
          const message =
            adaptor.getAttribute(error, 'data-mjx-error') || 'invalid TeX';
          failures.push(
            `${relativePath}:${formula.line + frontMatterLines} ${message}`
          );
        });
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        failures.push(
          `${relativePath}:${formula.line + frontMatterLines} ${message}`
        );
      }
    }
  }
}

if (failures.length > 0) {
  console.error(
    `Math validation failed: ${failures.length} issue(s) in ${formulaCount} formulas.`
  );
  console.error(failures.join('\n'));
  process.exitCode = 1;
} else {
  console.log(
    `Math validation passed: ${formulaCount} formulas in ${fileCount} Markdown files.`
  );
}
