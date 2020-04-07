# 準備
## パッケージの準備
library(tidyverse)
library(sf)
library(tmap)
library(tmaptools)

## 読み込み
# DIDデータの読み込み
tokyo <- st_read("A16-15_13_DID.geojson")
# 鉄道データの読み込み
rail <- st_read("N02-18_RailroadSection.geojson")
# 都市公園データの読み込み
park <- st_read("P13-11_13.shp", options = "ENCODING=CP932", crs = 4612) # エンコーディングとCRS（ここではJGD2000）を指定

## 編集
# DIDデータ
tokyo.proj <- st_transform(tokyo, crs = 6677)  %>% st_make_valid() # 投影変換と不正な地物の整形

# 鉄道データ
rail.proj <- st_transform(rail,  crs = 6677) # 投影変換
rail.proj.clip <- st_intersection(x = rail.proj, y = tokyo.proj) %>% mutate(`鉄道路線（運営会社）` = fct_drop(N02_004)) # DIDで切り出し、属性を追加

# 都市公園データ
park.proj <- st_transform(park, crs = 6677)
park.proj.clip <- st_intersection(x = park.proj, y = tokyo.proj) %>% mutate(`公園面積（m2）` = P13_008) # DIDで切り出し、属性を追加


# 描画
## モードの設定
tmap_mode("view")

## ポリゴンの描画とラベルの表示
tm_shape(shp = tokyo.proj) +
  tm_polygons(col = "gray") + 
  tm_text(text = "市町村名称")


## ラインの描画と類型による色分け
tm_shape(shp = rail.proj.clip) + 
  tm_lines(col = "鉄道路線（運営会社）", lwd = 2, palette = get_brewer_pal("Paired", n = 18)) 

## ポイントの描画と階級による色分け
tm_shape(shp = park.proj.clip) + 
  tm_dots(col = "公園面積（m2）", style = "quantile", size = 0.01,palette = get_brewer_pal("Greens"))

## レイヤの重ね合わせ
m <- tm_shape(shp = tokyo.proj) +
      tm_polygons(col = "gray") + 
      tm_text(text = "市町村名称") + 
     tm_shape(shp = rail.proj.clip) + 
      tm_lines(col = "鉄道路線（運営会社）", lwd = 2, palette = get_brewer_pal("Paired", n = 18)) + 
     tm_shape(shp = park.proj.clip) + 
      tm_dots(col = "公園面積（m2）", style = "quantile", size = 0.01,palette = get_brewer_pal("Greens")) + 
     tm_layout(title = "<p>東京のDID内の鉄道と都市公園</p><p><small>国土交通省国土政策局「国土数値情報（人口集中地区データ、鉄道データ、都市公園データ ）」（http://nlftp.mlit.go.jp/ksj/index.html）をもとにocean_fが編集、加工。</small></p>") 

m # 描画


# 保存とウェブ上での公開
## 保存
tmap_save(m, "tmap.html")
