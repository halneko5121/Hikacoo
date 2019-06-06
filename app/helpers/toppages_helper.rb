module ToppagesHelper

  def search_google_trand_word()
    
    # 20010101 形式で現在日付を取得
    date = DateTime.now.strftime('%Y%m%d')
    puts "現在日付 => #{date}"
    
    # google トレンド情報を取得
    uri = URI("https://trends.google.com/" + "trends/api/dailytrends" + "?geo=JP" + "&ed=#{date}")
    response_json = Net::HTTP.get(uri)

    # なんかゴミデータが残ってるので削除
    response_json[0, 5] = ''

    # JSON パース
    response_json = response_json.force_encoding("utf-8")
    response_data = JSON.parse(response_json)

=begin
    # テストコード
    File.open('.\Sample.json', 'w+') do |file|
      file.puts response_data
    end
=end

    # トレンドデータ取得（トレンドワード）
    trend_word_array = Array.new
    base_data   = response_data["default"]["trendingSearchesDays"][0]
    trend_datas = base_data["trendingSearches"]
    trend_datas.each do |trand_data|
      trend_word_array.push(trand_data["title"]["query"])
    end

    return trend_word_array
  end

  def search_rakuten(keyword, count)
    
    # パラメータ設定
    search_word     = URI.encode(keyword)
    rakuten_ecs_yml = YAML.load_file("#{Rails.root}/config/rakuten_ecs.yml")
    app_id          = "?applicationId=#{rakuten_ecs_yml['application_id']}"
    query           = "&keyword=#{search_word}"
    affiliate_id    = "&affiliate_id=#{rakuten_ecs_yml['affiliate_id']}"
    base_url        = "https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404"
    param_string    = "#{app_id}" + "#{query}" + "#{affiliate_id}"

    # リクエスト送信
    uri = URI("#{base_url}" + "#{param_string}")
    response_json = Net::HTTP.get(uri)
    response_json = response_json.force_encoding("utf-8")
    response_data = JSON.parse(response_json)

    array_items = Array.new
    
    # なにかしらのエラーが出ていたら表示して return
    if response_data["error"] != nil
      return array_items
    end

    items = response_data["Items"]
    items.first(count).each do |item|
      item_value = Hash.new
      item_value[:image_url]  = item["Item"]["mediumImageUrl"]
      item_value[:name]       = item["Item"]["title"]
      item_value[:price]      = "\ " + item["Item"]["itemPrice"].to_s(:delimited)
      item_value[:shop_url]   = item["Item"]["itemUrl"]
      item_value[:sales_date] = item["Item"]["salesDate"]
      item_value[:isbn_code]  = item["Item"]["isbn"]
      item_value[:jan_code]   = (item["Item"]["jan"] != "") ? item["Item"]["jan"] : item["Item"]["isbn"]
      array_items.push(item_value)
    end

    return array_items
  end

  def scraping_search_amazon_site(keyword, count)

    # 検索キーワードは空白を「+」に変換する
    search_word = keyword.gsub(" ", "+")

    # URL設定
    base_url        = "https://paboo.net/result/"
    request_url     = base_url + "?a_page=1&r_page=1&search=" + URI.encode(search_word)

    # スクレイピング先のURL
    charset = nil
    html = OpenURI.open_uri(URI(request_url)) do |f|
      charset = f.charset     # 文字種別を取得
      f.read                  # htmlを読み込んで変数htmlに渡す
    end

    # htmlをパース(解析)してオブジェクトを生成
    doc = Nokogiri::HTML.parse(html, nil, charset)

    # 指定件数の情報を取得
    array_items = Array.new
    count.times do |index|
      item_value = Hash.new
      
      # jan code
      doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/div/div/ul/li[2]/a").each do |chiled_node|
        value_string = chiled_node.attributes["href"].value
        
        # 不要な文字列を削除する
        value_array  = value_string.split(/(\?|\&)/)
        delete_list = ["/compare/", "?", "&"]
        value_array.delete_if do |str|
          delete_list.include?(str)
        end
        
        # 配列から「ean code」の要素だけ取得
        ean_code = value_array.select { |x|
          x[/(ean\=.*)/, 0]
        }
        ean_code = ean_code[0]
        ean_code[0, 4] = ''
        item_value[:jan_code] = ean_code
      end
    
      # Image URL
      doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/div/a/img").each do |node|
        item_value[:image_url] = node.attributes["src"].value
      end
      # Title / Shop URL
      doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/dl/dt/a").each do |node|
        item_value[:name] = node.children.text
        item_value[:shop_url] = node.attributes["href"].value
      end
      # Sales Lank
      is_enable_salesrank = true
      doc.xpath("//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[1]").each do |node|
        if !node.children.text.include?("SalesRank")
          is_enable_salesrank = false
        end
      end
      puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      puts is_enable_salesrank
      puts "xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

      price_str       = "//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[3]/span"
      sales_date_str  = "//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[4]"

      # Sales Lank が無い場合
      if !is_enable_salesrank
        price_str      = "//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[2]/span"
        sales_date_str = "//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[3]"
      end

      # Price
      doc.xpath("#{price_str}").each do |node|
        item_value[:price] = node.children.text 
      end

      # Price が無い場合
      if item_value[:price] == nil
        sales_date_str = "//*[@id='ama_res_in']/article[#{index+1}]/dl/dd[2]"
      end

      # Sales Date
      doc.xpath("#{sales_date_str}").each do |node|
        # 「発売日」を消したい
        temp_value = node.children.text
        temp_value[0, 5] = ''
        item_value[:sales_date] = temp_value
      end
      if !item_value.empty?
        array_items.push(item_value)
      end
    end

    return array_items
  end
end