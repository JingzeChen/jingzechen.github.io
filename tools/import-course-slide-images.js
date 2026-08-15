import fs from 'node:fs/promises';
import path from 'node:path';
import process from 'node:process';
import sharp from 'sharp';

const [sourceArgument, outputArgument] = process.argv.slice(2);

if (!sourceArgument || !outputArgument) {
  console.error('Usage: node tools/import-course-slide-images.js SOURCE_DIR OUTPUT_DIR');
  process.exit(1);
}

const sourceDirectory = path.resolve(sourceArgument);
const outputDirectory = path.resolve(outputArgument);
const course = JSON.parse(await fs.readFile(path.join(sourceDirectory, 'course.json'), 'utf8'));
const imagePattern = /\.(?:png|jpe?g|webp)$/i;
const concurrency = Math.max(1, Math.min(8, Number(process.env.SLIDE_CONCURRENCY) || 4));

async function mapWithConcurrency(items, worker) {
  let nextIndex = 0;
  const workers = Array.from({ length: Math.min(concurrency, items.length) }, async () => {
    while (nextIndex < items.length) {
      const index = nextIndex;
      nextIndex += 1;
      await worker(items[index], index);
    }
  });
  await Promise.all(workers);
}

let convertedDecks = 0;
let convertedSlides = 0;
let skippedDecks = 0;

for (const lecture of [...course.lectures].sort((left, right) => left.index - right.index)) {
  const lectureDirectory = path.join(sourceDirectory, lecture.directory.replaceAll('\\', '/'));
  const sourceSlidesDirectory = path.join(lectureDirectory, 'slides');
  let sourceSlides;

  try {
    sourceSlides = (await fs.readdir(sourceSlidesDirectory, { withFileTypes: true }))
      .filter((entry) => entry.isFile() && imagePattern.test(entry.name))
      .map((entry) => entry.name)
      .sort((left, right) => left.localeCompare(right, undefined, { numeric: true }));
  } catch (error) {
    if (error.code === 'ENOENT') continue;
    throw error;
  }

  if (sourceSlides.length === 0) continue;

  const slideDocument = (lecture.materials || []).find((material) => /\.(?:pdf|pptx?)$/i.test(material));
  const deckName = slideDocument
    ? path.basename(slideDocument, path.extname(slideDocument))
    : `lecture-${String(lecture.index).padStart(3, '0')}`;
  const deckOutput = path.join(outputDirectory, deckName);
  await fs.mkdir(deckOutput, { recursive: true });

  const expectedNames = sourceSlides.map((_, index) => `slide-${String(index + 1).padStart(4, '0')}.webp`);
  const existingNames = (await fs.readdir(deckOutput)).filter((name) => /^slide-\d+\.webp$/i.test(name)).sort();
  const complete = existingNames.length === expectedNames.length &&
    expectedNames.every((name, index) => name === existingNames[index]);

  if (complete) {
    skippedDecks += 1;
    console.log(`SKIP ${deckName} (${sourceSlides.length} slides)`);
    continue;
  }

  await Promise.all(existingNames.map((name) => fs.rm(path.join(deckOutput, name), { force: true })));
  await mapWithConcurrency(sourceSlides, async (sourceName, index) => {
    await sharp(path.join(sourceSlidesDirectory, sourceName))
      .resize({ width: 1024, height: 768, fit: 'contain', background: '#ffffff', withoutEnlargement: false })
      .webp({ quality: 82, effort: 4, smartSubsample: true })
      .toFile(path.join(deckOutput, expectedNames[index]));
  });

  convertedDecks += 1;
  convertedSlides += sourceSlides.length;
  console.log(`DONE ${deckName} (${sourceSlides.length} slides)`);
}

console.log(`Converted ${convertedSlides} slides from ${convertedDecks} decks; skipped ${skippedDecks} complete decks.`);
