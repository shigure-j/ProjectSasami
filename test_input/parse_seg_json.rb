def gen_table_row_head(table_hash)
  row_head = []

  point_stack = table_hash.to_a
  head_stack = [[]]
  flag_push = true 
  while 1
    if point_stack.size.eql?(0)
      break
    else
      point = point_stack.pop
      head = head_stack.pop
    end

    point_ary = point.to_a
    point_ary.each_with_index do |pair, index|
      key, value = pair
      if value.class.eql?(Hash)
        point_ary[(index+1)...point_ary.size].each do |n|
          point_stack.push n
          head_stack.push(key)
        end
        value.to_a.each {|n| point_stack.push n}
        break
      else
        row_head << (head_stack + 
      end
    end
end
