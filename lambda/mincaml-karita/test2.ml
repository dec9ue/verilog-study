let fold_string_with_sep sep f list = 
  List.fold_right (function x -> function y ->(f x) ^ sep ^ y) list "";;
let fold_string f list = fold_string_with_sep " ";;

let f1 (x1,x2) = (string_of_int x1) ^ (string_of_int x2);;
let f2 x = string_of_int x;;

let test2_1 = fold_string f1 [(34,34);(34,3421);(124,12)];;
let test2_2 = fold_string f2 [34;34;34;3421;124;12];;



