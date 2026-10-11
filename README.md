# Pipora Pay Helper

Pipora Pay Helper 是一個離線優先的 Flutter App，可依商店搜尋結果比較信用卡與付款方式的預估回饋，並在目前使用的裝置或瀏覽器本機記錄消費。

## 開發環境需求

- Flutter 3.44.0 或更新版本；專案目前的 Dart SDK 下限為 3.12.2。
- Chrome：執行 Web 版及進行瀏覽器手動驗收。
- Android Studio、Android SDK、platform-tools，以及可執行專案 Gradle 版本的 JDK：建置 Android 版。本機驗收使用 Android Studio JBR 25.0.2；Android 編譯目標為 Java 17。

確認本機工具鏈：

```sh
flutter doctor -v
flutter devices
```

## 安裝與啟動

在專案根目錄執行：

```sh
flutter pub get
flutter run -d chrome
```

使用 Android 模擬器或已連接裝置時，先啟動裝置並從 `flutter devices` 找到裝置 ID，再執行：

```sh
flutter run -d <device-id>
```

若 Flutter 沒有偵測到 Chrome，可執行 `flutter run -d web-server`，再用 Chrome 開啟 Flutter 顯示的本機網址。

## 測試與建置

```sh
dart format lib test
flutter analyze
flutter test
```

建置指令：

```sh
flutter build web --release
flutter build apk --debug
```

本次以 Flutter 3.44.7 成功完成 Web release 建置與 Android debug 建置。`flutter build apk --debug` 首次執行約 11 分 20 秒，下載 Gradle 9.1.0、Android SDK Platform 36 及 NDK 28.2.13676358 後成功產生 `build/app/outputs/flutter-apk/app-debug.apk`；使用的 Android Studio JBR 為 25.0.2，專案編譯目標為 Java 17。Android debug APK 僅供開發使用；正式版簽章與上架設定尚未完成。

## Chrome 繁體中文手動驗收清單

若要確保首次測試的累計數字可預期，請使用暫存的 Chrome 個人檔案。交易資料存在瀏覽器本機儲存空間；不要為了測試而清除日常使用的 Chrome 個人檔案資料。

1. 執行 `flutter run -d chrome` 並開啟本機 App，確認首頁、商店名稱欄位與消費金額欄位出現。
2. 輸入商店 `7-11`、消費金額 `10000` 後搜尋。確認推薦卡片顯示排名、信用卡、付款方式、回饋率及本筆預估回饋；再分別使用搜尋按鈕與商店欄位的 Enter／搜尋動作送出一次搜尋。
3. 找到「CUBE Card／LINE Pay」推薦。若當月尚無這張卡在 7-11 的消費紀錄，依內建範例規則，名目回饋率為 5%，本筆回饋會受 NT$300 上限限制；確認推薦卡與詳情頁都顯示回饋上限及剩餘額度。
4. 開啟該推薦的詳情並記錄消費。返回首頁、展開消費紀錄，確認新增一筆 7-11 消費，且本月累計回饋增加。
5. 開啟該筆明細，將實際回饋輸入 `120` 後儲存。確認明細改為 NT$120，本月累計依實際回饋更新；乾淨的暫存個人檔案中，本月累計應為 NT$120。
6. 重新載入瀏覽器頁面，確認該筆交易和 NT$120 實際回饋仍存在，沒有新增重複紀錄，本月累計也維持正確。
7. 再搜尋 `7-11`、金額 `10000`。確認 CUBE 這筆優惠剩餘額度為 NT$180（NT$300 上限扣除 NT$120 實際回饋），且下一筆預估回饋不超過剩餘額度。若測試個人檔案已有其他本月交易，請依已累計的實際或預估回饋核對，不要套用乾淨個人檔案的固定數字。

手動驗收紀錄請註明瀏覽器版本、作業系統、測試日期及結果差異。Flutter 測試或 Web 建置成功不代表已完成互動式 Chrome 驗收。

## 目前限制

- 信用卡、商店、付款方式及優惠規則來自 `assets/data/` 的靜態 JSON 範例資料，不會向銀行或支付服務即時更新。
- 回饋估算依目前資料處理回饋率、最低消費、活動回饋上限與每月上限；發卡機構的排除項目、登錄狀態、商店分類及結算差異可能沒有納入。付款前仍應確認發卡機構公告的完整條款。
- 實際回饋需由使用者在入帳後自行輸入。交易透過 SharedPreferences 儲存在目前瀏覽器來源或裝置，沒有帳號、雲端同步、匯出或備份；清除 App 或瀏覽器儲存資料可能使本機交易紀錄消失。
- 內建的 7-11／CUBE 範例每月及活動回饋上限為 NT$300，有效至 2026-12-31。範例優惠可能到期，使用前應檢查資料日期與實際活動條款。
- 2026-10-11 在 Windows 10.0.22631.6199 的 Codex In-app Browser（版本未回報）手動驗證 `7-11`／`10000` 搜尋、推薦、記錄消費、將實際回饋改為 `120`、重新載入及剩餘額度 `NT$180`；交易留在測試用瀏覽器的本機儲存。Flutter 偵測到 Chrome 155.0.8059.39 並能啟動 App，但目前 UI 自動化工作階段無法連接該 Chrome 視窗，因此 Chrome 互動式驗收仍待補。Web release 建置已通過。
- Android 正式版簽章與商店上架設定尚未完成。
