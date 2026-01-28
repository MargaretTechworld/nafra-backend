# Pagination helper for API responses
module PaginationHelper
  def paginate(collection, page: 1, per_page: 20)
    page = [page.to_i, 1].max
    per_page = [per_page.to_i, 1].max
    
    total_count = collection.count
    total_pages = (total_count / per_page.to_f).ceil
    offset = (page - 1) * per_page
    
    {
      data: collection.limit(per_page).offset(offset),
      pagination: {
        current_page: page,
        total_pages: total_pages,
        total_count: total_count,
        per_page: per_page
      }
    }
  end
end
