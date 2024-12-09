import { readFile } from "fs/promises";

const example = `
  2333133121414131402
  `;

/**
 * @param {string} text
 */
function parsePuzzle(text) {
  const res = [];
  const input = text.trim();
  let fileIndex = 0;
  for (let i = 0, l = input.length; i < l; i += 2) {
    const fileSize = input[i] - "0";
    const freeSize = (input[i + 1] ?? "0") - "0";
    res.push({
      index: fileIndex++,
      size: fileSize,
      freeEnd: freeSize,
    });
  }
  return res;
}

/**
 * @param {{ index: number; size: number; freeEnd: number}[]} disk
 */
function packFiles(disk) {
  let res = disk;
  for (let back = disk.length - 1; back > 1; back--) {
    const fileToPack = disk[back];
    // Find space to pack
    const packIntoIndex = res.findIndex(
      (v, i) => v.freeEnd >= fileToPack.size && i < back,
    );
    if (packIntoIndex === -1) continue;
    // Pack file
    const fileToPackIndexInRes = res.findIndex(v => v.index === fileToPack.index);
    res = res.filter(v => v.index !== fileToPack.index);
    const packIntoFile = res[packIntoIndex];
    res[fileToPackIndexInRes - 1].freeEnd += fileToPack.size + fileToPack.freeEnd;
    fileToPack.freeEnd = packIntoFile.freeEnd - fileToPack.size;
    packIntoFile.freeEnd = 0;
    res = [
      ...res.slice(0, packIntoIndex),
      packIntoFile,
      fileToPack,
      ...res.slice(packIntoIndex + 1),
    ];
  }
  return res;
}

function part2() {
  let disk = parsePuzzle(example);
  disk = packFiles(disk)
  console.log("part 2", disk);
}

part2();
