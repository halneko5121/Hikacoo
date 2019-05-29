class ToppagesController < ApplicationController
 before_action :check_search_validate, only: [:search]
  
  include ToppagesHelper
  
  def index
  end
  
  def search
    # rakuten_web_service内のclassで使えるようにアプリケーションIDを設定
    rakuten_ecs_yml = YAML.load_file("#{Rails.root}/config/rakuten_ecs.yml")
    RakutenWebService.configure do |options|
      options.application_id = rakuten_ecs_yml[:application_id] if rakuten_ecs_yml[:application_id].present?
      options.affiliate_id = rakuten_ecs_yml[:affiliate_id] if rakuten_ecs_yml[:affiliate_id].present?
    end

    keyword = params[:search_word][:title]
    puts "keyword ======> #{keyword}"

    # rakuten_web_serviceの使用法に乗っ取りHTTPリクエストを送ってデータを取得
    items = RakutenWebService::Ichiba::Item.search(keyword: keyword)
    @items = Array.new
    items.first(10).each do |item|
      item_value = Hash.new
      item_value[:medium_image_urls] = item["mediumImageUrls"][0]
      item_value[:name] = item["itemName"]
      item_value[:price] = item["itemPrice"]
      item_value[:shop_url] = item["affiliateUrl"]
      @items.push(item_value)
    end

    search_amazon(keyword)
  end
  
  private
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

  def search_amazon(keyword)
    init_amazon()
    res = Amazon::Ecs.item_search(
      keyword,
      response_group: 'ItemAttributes, Images, Offers',
      country:  'jp',
    )

    res.items.first(1).each do |item|
      p item.get("ItemAttributes/Title")
      p item.get("DetailPageURL")
      p item.get("MediumImage/URL")
      p item.get('Offers/Offer/OfferListing/Price/Amount') #値引き前(情報取得時点の)価格を¥表示)
    end
  end
  
  private
  def check_search_validate()
    search_word = params[:search_word][:title]
    if search_word == ""
      flash[:danger] = "検索ワードを入力してください"
      redirect_to root_url
    end
  end  
end
