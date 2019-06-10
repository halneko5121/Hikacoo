class ToppagesController < ApplicationController
  before_action :check_search_validate, only: [:search]
  before_action :update_trend_words, only: [:index, :search, :comparison]
  before_action :get_category_data, only: [:index, :search, :comparison]

  def index
    @trend_word = params[:commit]
  end
  
  def search

    # 検索
    @keyword      = params.require(:search_word).permit(:content)[:content]
    @category     = params.require(:category).permit(:content)[:content]
    record        = Category.find_by(code: @category)
    @category_name= record.name

    puts "keyword ======> #{@keyword}"
    puts "category ======> #{@category}（#{@category_name}）"
    @is_rakuten_books = Utils::RakutenApiUtil.is_rakuten_books_search(@category)
    @rakuten_item = Utils::RakutenApiUtil.search_rakuten(@keyword, @category, 10)
    @amazon_item = Utils::AmazonApiUtil.scraping_search_amazon_site(@keyword, @category, 10)
    update_item_database(Item, @rakuten_item)
    update_item_database(ComparisonItem, @amazon_item)
  end
  
  def comparison
    
    # 楽天商品から「比較」された
    # jan code で比較する
    if params["rakuten"] != nil
      item_name = params["rakuten"][:name]
      category  = params["rakuten"][:category]
      @rakuten_item = [Item.find_by(name: item_name)]
      @amazon_item = Utils::AmazonApiUtil.scraping_search_amazon_site(@rakuten_item[0].jan_code, category, 1)
      @is_rakuten_books = Utils::RakutenApiUtil.is_rakuten_books_search(category)

    # amazonから「比較」された
    # jan code で比較する
    elsif params["amazon"] != nil
      item_name = params["amazon"][:name]
      category  = params["amazon"][:category]
      @amazon_item = [ComparisonItem.find_by(name: item_name)]
      @rakuten_item = Utils::RakutenApiUtil.search_rakuten(@amazon_item[0].jan_code, 1)
      @is_rakuten_books = Utils::RakutenApiUtil.is_rakuten_books_search(category)
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
          sales_date: "#{item[:sales_date]}",
          isbn_code: "#{item[:isbn_code]}",
          jan_code: "#{item[:jan_code]}"
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
    trend_words = Utils::TrendwordUtil.search_trand_word()
    trend_words = trend_words.shuffle
    @trend_word_first  = trend_words[0, 3]
    @trend_word_second = trend_words[4, 3]

    @trend_word_count = 0
    if @trend_word_second != nil
      @trend_word_count = @trend_word_first.size + @trend_word_second.size
    else
      @trend_word_count = @trend_word_first.size
    end
  end
  
  def get_category_data
    @category_data = Category.all
  end
end
