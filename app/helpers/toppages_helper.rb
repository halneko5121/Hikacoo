module ToppagesHelper

  def search_rakuten(keyword)
    init_rakuten()
    
    # rakuten_web_serviceの使用法に乗っ取りHTTPリクエストを送ってデータを取得
    array_items = Array.new
    items = RakutenWebService::Ichiba::Item.search(keyword: keyword)
    items.first(10).each do |item|
      item_value = Hash.new
      item_value[:image_url] = item["mediumImageUrls"][0]
      item_value[:name] = item["itemName"]
      item_value[:price] = item["itemPrice"]
      item_value[:shop_url] = item["affiliateUrl"]
      array_items.push(item_value)
    end
    
    return array_items
  end

  def search_amazon(keyword)
    init_amazon()
    res = Amazon::Ecs.item_search(
      keyword,
      response_group: 'ItemAttributes, Images, Offers',
      country:  'jp',
    )

    array_items = Array.new
    res.items.first(10).each do |item|
      item_value = Hash.new
      item_value[:image_url] = item.get("MediumImage/URL")
      item_value[:name] = item.get("ItemAttributes/Title")
      item_value[:price] = item.get('Offers/Offer/OfferListing/Price/Amount')
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
    Amazon::Ecs.configure do |options|
      keys.each do |key|
        options[key] = amazon_ecs_yml[key.to_s] if amazon_ecs_yml[key.to_s].present?
      end
    end
  end
end