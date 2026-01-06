import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import statsmodels.api as sm
import numpy as np
import warnings

# 忽略不必要的警告
warnings.filterwarnings('ignore')

# --- 0. 環境設定 ---
plt.rcParams['font.sans-serif'] = ['Microsoft JhengHei']  # 解決中文亂碼
plt.rcParams['axes.unicode_minus'] = False
plt.style.use('ggplot')

print("🚀 開始執行空氣品質分析專案...")

# --- 1. 資料讀取與清理 (Data Cleaning) ---
try:
    # 讀取資料 (請確認檔案跟程式在同一層資料夾)
    df = pd.read_csv('淡水_2024.csv', encoding='utf-8', engine='python')

    # 處理橫式資料 (00-23小時) -> 轉直
    hour_cols = [str(i).zfill(2) for i in range(24)]
    df_melt = df.melt(id_vars=['日期', '測項'], value_vars=hour_cols, var_name='Hour', value_name='Value')

    # 轉數值 (非數值變 NaN)
    df_melt['Value'] = pd.to_numeric(df_melt['Value'], errors='coerce')

    # 建立時間索引
    df_melt['Datetime'] = pd.to_datetime(df_melt['日期']) + pd.to_timedelta(df_melt['Hour'].astype(int), unit='h')

    # 樞紐分析 (Pivot)：讓每個汙染物變成獨立欄位
    df_clean = df_melt.pivot_table(index='Datetime', columns='測項', values='Value', aggfunc='first')
    
    print(f"✅ 資料整理完成！樣本數：{len(df_clean)} 筆")

except Exception as e:
    print(f"❌ 讀取失敗，請檢查檔名或路徑。\n錯誤訊息: {e}")
    exit()

# --- 2. 特徵工程 (Feature Engineering) ---
# 加入「尖峰時刻 (RushHour)」變數 (7-9點, 17-19點)
hours = df_clean.index.hour
df_clean['RushHour'] = ((hours >= 7) & (hours <= 9)) | ((hours >= 17) & (hours <= 19))
df_clean['RushHour'] = df_clean['RushHour'].astype(int)

# --- 3. 統計分析：多元迴歸模型 (OLS Regression) ---
print("\n📊 正在進行統計檢定 (分析汙染源)...")

# 定義自變數 (X): 包含 氣象 + 交通指標(CO) + 工廠指標(SO2) + 尖峰時刻
# 這裡會自動偵測你的資料有沒有這些欄位，有的才加進去
potential_features = ['WIND_SPEED', 'AMB_TEMP', 'O3', 'NO2', 'CO', 'SO2', 'RushHour']
features = [f for f in potential_features if f in df_clean.columns]

if 'PM2.5' in df_clean.columns and len(features) > 0:
    # 準備數據 (移除空值)
    df_model = df_clean[features + ['PM2.5']].dropna()
    
    X = df_model[features]
    y = df_model['PM2.5']
    
    # 加入截距項 (常數)
    X = sm.add_constant(X)
    
    # 訓練模型
    model = sm.OLS(y, X).fit()
    
    # 整理結果表格
    summary_df = pd.DataFrame({
        '係數 (Coef)': model.params,
        'P值 (P-value)': model.pvalues,
        '顯著性': model.pvalues.apply(lambda x: '*** (極顯著)' if x < 0.001 else ('** (顯著)' if x < 0.05 else ''))
    })
    
    # 移除截距項不看，並排序
    if 'const' in summary_df.index: summary_df = summary_df.drop('const')
    summary_df = summary_df.sort_values(by='P值 (P-value)')
    
    print("\n=== 🎯 PM2.5 影響因子分析表 ===")
    display(summary_df)
    
    # 特別解讀 CO (交通)
    if 'CO' in summary_df.index:
        co_p = summary_df.loc['CO', 'P值 (P-value)']
        co_coef = summary_df.loc['CO', '係數 (Coef)']
        print(f"\n💡 交通指標 (CO) 分析：係數={co_coef:.2f}, P值={co_p:.4f}")
        if co_p < 0.05 and co_coef > 0:
            print("👉 結論：統計證實「汽機車排放 (CO)」顯著增加 PM2.5 濃度。")
        else:
            print("👉 結論：數據上未發現 CO 與 PM2.5 有顯著正相關。")

# --- 4. 視覺化：24小時趨勢疊合圖 (Trend Analysis) ---
print("\n📈 正在繪製 24 小時趨勢對比圖...")

# 計算每小時平均
hourly_avg = df_clean.groupby(df_clean.index.hour).mean(numeric_only=True)

# 數據標準化 (歸一化到 0~1 之間，方便畫在同一張圖比較波形)
cols_to_plot = ['PM2.5', 'CO', 'NO2']
plot_data = hourly_avg[cols_to_plot].copy()
plot_data = (plot_data - plot_data.min()) / (plot_data.max() - plot_data.min())

plt.figure(figsize=(12, 6))

# 畫線
sns.lineplot(data=plot_data['PM2.5'], label='PM2.5 (細懸浮微粒)', color='red', linewidth=3, marker='o')
if 'CO' in plot_data.columns:
    sns.lineplot(data=plot_data['CO'], label='CO (汽機車指標)', color='green', linestyle='--')
if 'NO2' in plot_data.columns:
    sns.lineplot(data=plot_data['NO2'], label='NO2 (柴油車/燃燒指標)', color='blue', linestyle=':')

# 標示尖峰
plt.axvspan(7, 9, color='gray', alpha=0.15, label='上班尖峰')
plt.axvspan(17, 19, color='gray', alpha=0.15, label='下班尖峰')

plt.title('淡水 PM2.5 與 交通排放(CO/NO2) 之 24小時趨勢疊合', fontsize=14)
plt.xlabel('時間 (00:00 - 23:00)')
plt.ylabel('標準化濃度 (趨勢指標 0-1)')
plt.legend()
plt.xticks(range(24))
plt.grid(True)
plt.show()

print("✅ 所有分析完成！")