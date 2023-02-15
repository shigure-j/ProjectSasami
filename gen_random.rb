all_works = Work.all.to_a
all_works.each do |work|
  upstream = (all_works - [work]).shuffle.first
  work.upstream = upstream
  work.save
  p upstream.id
  nil
end
