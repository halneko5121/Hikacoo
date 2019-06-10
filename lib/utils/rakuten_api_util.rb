module Utils
  class RakutenApiUtil
    
    # クラスメソッド
    def self.is_rakuten_books_search(category)
  
      rakuten_books_category = search_rakuten_books_category(category)
      if rakuten_books_category != ""
        return true
      else
        return false
      end
    end
  
    def self.search_rakuten(keyword, category, count)
  
      rakuten_books_category = search_rakuten_books_category(category)
      if rakuten_books_category != ""
        return search_rakuten_books(keyword, rakuten_books_category, count)
      else
        rakuten_ichiba_category = search_rakuten_ichiba_category(category)
        return search_rakuten_ichiba(keyword, rakuten_ichiba_category, count)
      end
    end

    def self.search_rakuten_books(keyword, category, count)
      
      # パラメータ設定
      search_word     = URI.encode(keyword)
      app_id          = "?applicationId=#{ENV['R_APPLICATION_ID']}"
      query           = "&keyword=#{search_word}"
      affiliate_id    = "&affiliate_id=#{ENV['R_AFFILIATE_ID']}"
      genre_id        = "&booksGenreId=#{category}"
      field           = "&field=0"
      base_url        = "https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404"
      param_string    = "#{app_id}" + "#{query}" + "#{affiliate_id}" + "#{genre_id}" + "#{field}"
  
      # リクエスト送信
      uri = URI("#{base_url}" + "#{param_string}")
      response_json = Net::HTTP.get(uri)
      response_json = response_json.force_encoding("utf-8")
      response_data = JSON.parse(response_json)
  
      array_items = Array.new
      
      # なにかしらのエラーが出ていたら return
      if response_data["error"] != nil
        return array_items
      end
  
      items = response_data["Items"]
      items.first(count).each do |item|
        item_value = Hash.new
        item_value[:image_url]  = item["Item"]["largeImageUrl"]
        item_value[:name]       = item["Item"]["title"]
        item_value[:price]      = "¥ " + item["Item"]["itemPrice"].to_s(:delimited)
        item_value[:shop_url]   = item["Item"]["itemUrl"]
        item_value[:sales_date] = item["Item"]["salesDate"]
        item_value[:isbn_code]  = item["Item"]["isbn"]
        item_value[:jan_code]   = (item["Item"]["jan"] != "") ? item["Item"]["jan"] : item["Item"]["isbn"]
        array_items.push(item_value)
      end
  
      return array_items
    end

    def self.search_rakuten_ichiba(keyword, category, count)
  
      # パラメータ設定
      search_word     = URI.encode(keyword)
      app_id          = "?applicationId=#{ENV['R_APPLICATION_ID']}"
      query           = "&keyword=#{search_word}"
      affiliate_id    = "&affiliateId=#{ENV['R_AFFILIATE_ID']}"
      genre_id        = "&genreId=#{category}"
      field           = "&field=0"
      base_url        = "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706"
      param_string    = "#{app_id}" + "#{query}" + "#{affiliate_id}" + "#{genre_id}" + "#{field}"
  
      # リクエスト送信
      uri = URI("#{base_url}" + "#{param_string}")
      response_json = Net::HTTP.get(uri)
      response_json = response_json.force_encoding("utf-8")
      response_data = JSON.parse(response_json)
  
      array_items = Array.new
      
      # なにかしらのエラーが出ていたら return
      if response_data["error"] != nil
        return array_items
      end
  
      items = response_data["Items"]
      items.first(count).each do |item|
        
        item_value = Hash.new
        image_url  = item["Item"]["mediumImageUrls"]
        item_value[:image_url]  = image_url[0]["imageUrl"]
        item_value[:name]       = item["Item"]["itemName"]
        item_value[:price]      = "¥ " + item["Item"]["itemPrice"].to_s(:delimited)
        item_value[:shop_url]   = item["Item"]["itemUrl"]
        item_value[:sales_date] = nil
        item_value[:isbn_code]  = nil
        item_value[:jan_code]   = nil
        array_items.push(item_value)
      end
  
      return array_items
    end

    def self.search_rakuten_books_category(category)
      rakuten_books_categories = {
        "books"    => "001",    # 本 
        "w_books"  => "005",    # 洋書
        "magazine" => "007",    # 雑誌
        "music"    => "002",    # 音楽（CD）
        "game"     => "006",    # ゲーム
        "dvd"      => "003",    # DVD（DVD・ブルーレイ）
      }
  
      # 楽天books に該当するカテゴリかどうか
      rakuten_books_category = ""
      rakuten_books_categories.each do |key, value|
        if category == key
          rakuten_books_category = value
        end
      end
  
      return rakuten_books_category
    end

    def self.search_rakuten_ichiba_category(category)
      rakuten_ichiba_categories = {
        "books"       => "200162", # 本・雑誌・コミック 
        "w_books"     => "101297", # 洋書
        "magazine"    => "101302", # 雑誌
        "music"       => "101240", # 音楽（CD・DVD・楽器）
        "game"        => "101205", # ゲーム
        "dvd"         => "101354", # DVD
        "pc"          => "100026", # PCソフト/周辺機器
  
        "all"         => "0",      # カテゴリ指定なし
        "electronics" => "562637", # 家電
        "kitchen"     => "558944", # キッチン用品（キッチン用品・食器・調理器具）
        "stationary"  => "100901", # 文房具
        "sports"      => "101070", # スポーツ・アウトドア
        "hobby"       => "101164", # おもちゃ・ホビー（おもちゃ・ホビー・ゲーム）
        "watch"       => "558929", # 時計（腕時計）
        "jewelry"     => "216129", # ジュエリー（ジュエリー・アクセサリー）
      }
      
      # 楽天books に該当するカテゴリかどうか
      rakuten_ichiba_category = ""
      rakuten_ichiba_categories.each do |key, value|
        if category == key
          rakuten_ichiba_category = value
        end
      end
  
      return rakuten_ichiba_category
    end
    
    private_class_method :search_rakuten_books
    private_class_method :search_rakuten_ichiba
    private_class_method :search_rakuten_books_category
    private_class_method :search_rakuten_ichiba_category
  end
end