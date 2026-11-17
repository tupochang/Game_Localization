
import fs from "node:fs/promises";
import { Workbook, SpreadsheetFile } from "@oai/artifact-tool";

const [, , inventory, output, directory] = process.argv;
const data = JSON.parse(await fs.readFile(inventory, "utf8"));
const workbook = Workbook.create();
const headers = ["編號", "類型", "英文原文", "繁體中文（可編輯）", "校對狀態", "校對備註", "來源檔案", "來源位置", "場景／項目"];
const widths = [82, 135, 405, 405, 110, 205, 175, 320, 205];
for (const [index, [name, rows]] of Object.entries(data).entries()) {
  const sheet = workbook.worksheets.add(name);
  const last = rows.length + 1;
  const whole = sheet.getRange("A1:I" + last);
  whole.format.font.name = "Microsoft JhengHei";
  whole.format.font.size = 11;
  whole.format.verticalAlignment = "top";
  whole.format.wrapText = true;
  whole.setNumberFormat("@");
  whole.values = [headers, ...rows];
  const table = sheet.tables.add("A1:I" + last, true, "Review" + (index + 1));
  table.style = "TableStyleMedium2";
  table.showFilterButton = true;
  sheet.showGridLines = false;
  sheet.freezePanes.freezeRows(1);
  for (const [column, width] of widths.entries()) {
    sheet.getRangeByIndexes(0, column, last, 1).format.columnWidthPx = width;
  }
  const header = sheet.getRange("A1:I1");
  header.format.fill = "#17374D";
  header.format.font.color = "#FFFFFF";
  header.format.font.bold = true;
  header.format.verticalAlignment = "center";
  header.format.rowHeightPx = 32;
  sheet.getRange("A2:I" + last).format.rowHeightPx = 38;
  sheet.getRange("D2:D" + last).format.fill = "#E5F4F1";
  sheet.getRange("D2:D" + last).format.font.color = "#154740";
  for (const [i, row] of rows.entries()) {
    const lengths = [2, 3, 7, 8].map(col => String(row[col]).split("\n").reduce((sum, line) => {
      const weighted = [...line].reduce((n, c) => n + (c.charCodeAt(0) > 255 ? 2 : 1), 0);
      const capacity = {2:52, 3:52, 7:38, 8:25}[col];
      return sum + Math.max(1, Math.ceil(weighted / capacity));
    }, 0));
    const lines = Math.max(...lengths);
    if (lines > 2) sheet.getRangeByIndexes(i + 1, 0, 1, 9).format.rowHeightPx = Math.min(500, lines * 18 + 8);
  }
}
const guide = workbook.worksheets.add("校對說明");
const instructions = [
  ["項目", "操作方式"],
  ["校對譯文", "直接修改 D 欄「繁體中文」。可在 E 欄改成「已校對」，並在 F 欄記下用詞或疑問。"],
  ["篩選與排序", "用表頭篩選類型、校對狀態或場景。請以整個表格為單位排序，讓譯文與來源位置保持對應。"],
  ["選項", "「選項」與「選項分支」會各自列出。調整同一選項時，請同步修訂兩列。"],
  ["控制碼", "保留反斜線控制碼與格式佔位符，例如 \\C[14]、\\LSPI[90]、%1。角色與圖鑑附註也含有引擎標記。"],
  ["來源位置", "來源檔案和位置可追溯至強化版遊戲資料。@JSON 表示外掛欄位內另有一層 JSON。@line 後面是附註欄位的行號。"],
  ["資料來源", "強化版 v2.00 的套用前備份與目前已安裝的繁中檔案。譯文包含原版沿用譯文及本機機器翻譯。"],
  ["目前範圍", "三個分頁涵蓋補丁內的文字及相關事件欄位。標題圖英文和執行時生成、仍未盤點的文字另行處理。"],
  ["補丁與 Excel", "壓縮檔使用目前的譯文。修改本表後，需將修訂套回遊戲資料並重建補丁。"]
];
guide.showGridLines = false;
const guideRange = guide.getRange("A1:B" + instructions.length);
guideRange.values = instructions;
guideRange.format.font.name = "Microsoft JhengHei";
guideRange.format.font.size = 11;
guideRange.format.wrapText = true;
guideRange.format.rowHeightPx = 43;
guideRange.format.verticalAlignment = "center";
guide.getRange("A:A").format.columnWidthPx = 155;
guide.getRange("B:B").format.columnWidthPx = 700;
guide.getRange("A1:B1").format.fill = "#17374D";
guide.getRange("A1:B1").format.font.color = "#FFFFFF";
guide.getRange("A1:B1").format.font.bold = true;
workbook.recalculate();
for (const [index, name] of [...Object.keys(data), "校對說明"].entries()) {
  const preview = await workbook.render({sheetName: name, range: index === 3 ? "A1:B9" : "A1:E6", scale: 1, format: "png"});
  await fs.writeFile(directory + "/workbook-preview-" + index + ".png", new Uint8Array(await preview.arrayBuffer()));
}
const result = await workbook.inspect({kind: "table", range: "劇情與事件!A1:E5", tableMaxRows: 5, tableMaxCols: 5});
console.log(result.ndjson);
await (await SpreadsheetFile.exportXlsx(workbook)).save(output);
