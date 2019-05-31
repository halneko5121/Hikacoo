module ToppagesHelper

  def search_google_trand_word()
    
    # 20010101 形式で現在日付を取得
    data = DateTime.now.strftime('%Y%m%d')
    puts "現在日付 => #{data}"
    
    # google トレンド情報を取得
    uri = URI("https://trends.google.com/" + "trends/api/dailytrends" + "?geo=JP" + "&ed=#{data}")
    response_json = Net::HTTP.get(uri)

    # なんかゴミデータが残ってるので削除
    response_json[0, 5] = ''

    response_json = response_json.force_encoding("utf-8")
    response_data = JSON.parse(response_json)

=begin
    # テストコード
    File.open('.\Sample.json', 'w+') do |file|
      file.puts response_data
    end
=end

    base_data = response_data["default"]["trendingSearchesDays"][0]

    # トレンドデータ取得（トレンドワード）
    trend_word_array = Array.new
    trend_datas = base_data["trendingSearches"]
    trend_datas.each do |trand_data|
      trend_word_array.push(trand_data["title"]["query"])
    end

    return trend_word_array
  end

  def search_yahoo_shopping(keyword, count)
    
    # パラメータ設定
    search_word = URI.encode(keyword)
    yahoo_ecs_yml = YAML.load_file("#{Rails.root}/config/yahoo_ecs.yml")
    app_id = "?appid=#{yahoo_ecs_yml['appid']}"
    query  = "&query=#{search_word}"
    condition = "&condition=new"
    affiliate_type = "&affiliate_type=vc"
    temp_affi_id = URI.encode(yahoo_ecs_yml["affiliate_id"])
    affiliate_id = "&affiliate_id=#{temp_affi_id}"

    # リクエスト送信
    uri = URI("https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch" + "#{app_id}" + "#{query}" + "#{condition}" + "#{affiliate_type}" + "#{affiliate_id}" )
    response_json = Net::HTTP.get(uri)
    response_json = response_json.force_encoding("utf-8")
    response_data = JSON.parse(response_json)
    
    # 情報の設定
    array_items = Array.new
    base_data = response_data["ResultSet"]["0"]["Result"]
    count.times do |index|
      item = base_data["#{index}"]
      item_value = Hash.new
      item_value[:image_url] = item["Image"]["Medium"]
      item_value[:name] = item["Name"]
      item_value[:price] = item["Price"]["_value"]
      item_value[:shop_url] = item["Url"]
      array_items.push(item_value)

      puts "mmmmmmmmmmmmmmmmmmmm"
      p item
      puts "mmmmmmmmmmmmmmmmmmmm"
end
    
    return array_items
  end

  def search_rakuten(keyword, count)
    
    # パラメータ設定
    search_word = URI.encode(keyword)
    rakuten_ecs_yml = YAML.load_file("#{Rails.root}/config/rakuten_ecs.yml")
    app_id = "?applicationId=#{rakuten_ecs_yml['application_id']}"
    query  = "&keyword=#{search_word}"
    affiliate_id = "&affiliate_id=#{rakuten_ecs_yml['affiliate_id']}"

    # リクエスト送信
    uri = URI("https://app.rakuten.co.jp/services/api/BooksTotal/Search/20170404" + "#{app_id}" + "#{query}" + "#{affiliate_id}")
    response_json = Net::HTTP.get(uri)
    response_json = response_json.force_encoding("utf-8")
    response_data = JSON.parse(response_json)

    array_items = Array.new
    items = response_data["Items"]
    items.first(count).each do |item|
      item_value = Hash.new
      item_value[:image_url] = item["Item"]["mediumImageUrl"]
      item_value[:name] = item["Item"]["title"]
      item_value[:price] = item["Item"]["itemPrice"]
      item_value[:shop_url] = item["Item"]["itemUrl"]
      array_items.push(item_value)
    end

=begin
    items = RakutenWebService::Ichiba::Item.search(keyword: search_word)
    items.first(count).each do |item|
      item_value = Hash.new
      item_value[:image_url] = item["mediumImageUrls"][0]
      item_value[:name] = item["itemName"]
      item_value[:price] = item["itemPrice"]
      item_value[:shop_url] = item["affiliateUrl"]
      array_items.push(item_value)
    end
=end
    
    return array_items
  end

  def search_amazon(keyword, count)
    init_amazon()
    res = Amazon::Ecs.item_search(
      keyword,
      response_group: 'ItemAttributes, Images, OfferSummary',
      country: 'jp',
    )

    array_items = Array.new
    res.items.first(count).each do |item|
#      puts item.get_element('OfferSummary')
      item_value = Hash.new
      item_value[:image_url] = item.get("MediumImage/URL")
      item_value[:name] = item.get("ItemAttributes/Title")
#      item_value[:price] = item.get('Offers/Offer/OfferListing/Price/Amount')
      item_value[:price] = item.get('OfferSummary/LowestNewPrice/Amount')
      item_value[:shop_url] = item.get("DetailPageURL")
      array_items.push(item_value)
    end
    
    return array_items
  end
  
  private
  def init_rakuten()
  
    # rakuten_web_service内のclassで使えるようにアプリケーションIDを設定
    rakuten_ecs_yml = YAML.load_file("#{Rails.root}/config/rakuten_ecs.yml")
    RakutenWebService.configure do |options|
      options.application_id = rakuten_ecs_yml["application_id"] if rakuten_ecs_yml["application_id"].present?
      options.affiliate_id = rakuten_ecs_yml["affiliate_id"] if rakuten_ecs_yml["affiliate_id"].present?
    end
  end

  def init_amazon()

    # このaccess_keyとsecret_keyは、associate画面から取得できるkeyを使う
    amazon_ecs_yml = YAML.load_file("#{Rails.root}/config/amazon_ecs.yml")
    keys = [:AWS_access_key_id, :AWS_secret_key, :associate_tag]
    Amazon::Ecs.debug = true
    Amazon::Ecs.configure do |options|
      keys.each do |key|
        options[key] = amazon_ecs_yml[key.to_s] if amazon_ecs_yml[key.to_s].present?
      end
    end
  end
end