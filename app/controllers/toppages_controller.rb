class ToppagesController < ApplicationController
  before_action :check_search_validate, only: [:search]
  before_action :update_trend_words, only: [:index, :search, :comparison]

  include ToppagesHelper
  
  def index
    @trend_word = params[:commit]
  end
  
  def search

    # 検索
    keyword = params.require(:search_word).permit(:content)[:content]

    puts "keyword ======> #{keyword}"
    @rakuten_item = search_rakuten(keyword, 10)
    @amazon_item = scraping_search_amazon_site(keyword, 10)
    update_item_database(Item, @rakuten_item)
    update_item_database(ComparisonItem, @amazon_item)
  end
  
  def comparison

    # 楽天商品から「比較」された
    if params["rakuten"] != nil
      item_name = params["rakuten"][:name]
      @rakuten_item = [Item.find_by(name: item_name)]
      @amazon_item = scraping_search_amazon_site(item_name, 1)
      
    # amazonから「比較」された
    elsif params["amazon"] != nil
      item_name = params["amazon"][:name]
      @rakuten_item = search_rakuten(item_name, 1)
      @amazon_item = [ComparisonItem.find_by(name: item_name)]
    end
  end
  
  private
  def update_item_database(database_name, update_items)
  
    # 何かしら入っていたら全削除
    items = database_name.all
    if !items.empty?
      database_name.delete_all
    end
    
    update_items.each do |item|
  
      # 存在しなければレコード保存
      if database_name.find_by(name: item[:name]) == nil
        item_record = database_name.new(
          name: "#{item[:name]}", price: "#{item[:price]}",
          image_url: "#{item[:image_url]}", shop_url: "#{item[:shop_url]}",
          sales_date: "#{item[:sales_date]}"
        )
        item_record.save
      end
    end
  end

  def check_search_validate()

    search_word = params.require(:search_word).permit(:content)[:content]
    if search_word == ""
      flash[:danger] = "検索ワードを入力してください"
      redirect_to root_url
    end
  end
  
  def update_trend_words

    # 中身をシャッフルして格納
    trend_words = search_google_trand_word()
    trend_words = trend_words.shuffle
    @trend_word_first  = trend_words[0, 3]
    @trend_word_second = trend_words[4, 3]
  end
end
