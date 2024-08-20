# frozen_string_literal: true

MAX_SIZE = 3
def entry_time(s, keypad)
  pos_map = {}
  keypad.chars.each_with_index do |digit, i|
    row = i / MAX_SIZE
    col = i % MAX_SIZE
    pos_map[digit] = [row, col]
  end

  total_time = 0
  (1...s.length).each do |i|
    prev_digit = s[i - 1]
    curr_digit = s[i]
    prev_pos = pos_map[prev_digit]
    curr_pos = pos_map[curr_digit]

    y = (prev_pos[0] - curr_pos[0]).abs
    x = (prev_pos[1] - curr_pos[1]).abs
    total_time += [y, x].max
  end
  total_time
end

s = '423692'
keypad = '923857614'
pp entry_time(s, keypad)
