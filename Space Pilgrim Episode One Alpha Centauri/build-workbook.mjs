import fs from "node:fs/promises";
import { SpreadsheetFile, Workbook } from "@oai/artifact-tool";

const [, , inventory, output, previewPath] = process.argv;
if (!inventory || !output) {
  throw new Error("Usage: node build-workbook.mjs inventory.json output.xlsx [preview.png]");
}
const { sheets } = JSON.parse(await fs.readFile(inventory, "utf8"));
const workbook = Workbook.create();
const tabs = [
  ["劇情事件", "EventText"],
  ["資料庫與系統", "DatabaseText"],
  ["圖像與外部文字", "AssetText"],
  ["腳本待核對", "ReviewText"],
];
const headers = ["編號", "類型", "原文", "繁體中文", "來源檔案", "來源位置", "備註"];

for (const [name, tableName] of tabs) {
  const sheet = workbook.worksheets.add(name);
  const rows = sheets[name];
  const last = rows.length + 1;
  const range = sheet.getRange(`A1:G${last}`);
  range.format.font.name = "Microsoft JhengHei";
  range.format.font.size = 10;
  range.format.verticalAlignment = "top";
  range.values = [headers, ...rows];
  const table = sheet.tables.add(`A1:G${last}`, true, tableName);
  table.style = "TableStyleMedium2";
  table.showFilterButton = true;

  sheet.showGridLines = false;
  sheet.freezePanes.freezeRows(1);
  const widths = [92, 168, 422, 360, 254, 427, 300];
  for (let col = 0; col < widths.length; col++) {
    sheet.getRangeByIndexes(0, col, last, 1).format.columnWidthPx = widths[col];
  }
  const heading = sheet.getRange("A1:G1");
  heading.format.fill = "#183650";
  heading.format.font.color = "#FFFFFF";
  heading.format.font.bold = true;
  heading.format.verticalAlignment = "center";
  heading.format.rowHeightPx = 29;
  const body = sheet.getRange(`A2:G${last}`);
  body.format.wrapText = true;
  body.format.rowHeightPx = 34;
  const translation = sheet.getRange(`D2:D${last}`);
  translation.setNumberFormat("@");
  translation.format.fill = "#E9F5FB";
  translation.format.font.color = "#174864";

  for (const [i, row] of rows.entries()) {
    const lineCount = Math.max(...[2, 5, 6].map((col) => {
      const limit = col === 6 ? 45 : 64;
      return (row[col] ?? "").split(/\r?\n/).reduce((sum, line) => {
        return sum + Math.max(1, Math.ceil(line.length / limit));
      }, 0);
    }));
    if (lineCount > 2) {
      sheet.getRange(`A${i + 2}:G${i + 2}`).format.rowHeightPx =
        Math.min(480, 17 * lineCount + 4);
    }
  }
}

const guide = workbook.worksheets.add("填寫說明");
guide.showGridLines = false;
guide.getRange("A1:B8").values = [
  ["工作表", "填寫方式"],
  ["劇情事件", "逐條填寫「繁體中文」。選項和選項分支標籤保留各自的來源位置，對應列請用相同譯文。"],
  ["資料庫與系統", "包含遊戲選單詞彙、道具、角色和預設資料庫。已填入三個通過測試的主選單譯文。"],
  ["圖像與外部文字", "含標題、結束畫面、可辨讀的招牌和 Credits.txt。圖像上的文字需從素材製作翻譯版本。"],
  ["腳本待核對", "包含介面與任務日誌候選，也保留註解、素材名稱和其他內部字串作核對。依畫面用途判斷是否填寫。"],
  ["控制碼", "保留原文的 RGSS 控制碼、Ruby 插值與格式佔位符，例如 \\C[1]、#{name}、%s。"],
  ["資料來源", "Steam 安裝版的原始 Game.rgss3a、Credits.txt、Game.ini 與可辨讀圖像。"],
  ["核對範圍", "腳本為靜態掃描。執行時組成的文字、Steam 平台文字和像素圖細字，需另在畫面上確認。"],
];
guide.getRange("A1:A8").format.columnWidthPx = 180;
guide.getRange("B1:B8").format.columnWidthPx = 660;
guide.getRange("A1:B8").format.font.name = "Microsoft JhengHei";
guide.getRange("A1:B8").format.wrapText = true;
guide.getRange("A1:B8").format.rowHeightPx = 34;
guide.getRange("A1:B1").format.fill = "#183650";
guide.getRange("A1:B1").format.font.color = "#FFFFFF";
guide.getRange("A1:B1").format.font.bold = true;

workbook.recalculate();
const inspection = await workbook.inspect({
  kind: "table", sheetId: "劇情事件", range: "A1:D5", tableMaxRows: 4, tableMaxCols: 4,
});
console.log(inspection.ndjson);
const result = await SpreadsheetFile.exportXlsx(workbook);
await result.save(output);
if (previewPath) {
  const preview = await workbook.render({
    sheetName: "劇情事件", range: "A1:D9", scale: 1, format: "png",
  });
  await fs.writeFile(previewPath, new Uint8Array(await preview.arrayBuffer()));
}
