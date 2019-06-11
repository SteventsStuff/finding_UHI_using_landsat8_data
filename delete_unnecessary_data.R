# set up working dirs
current_WD <- "D:/vova/diploma/LST/LST_using_R/main_script/dowloaded_data"
scene_dir_name <- "LC08_L1TP_178026_20181018_20181031_01_T1_LEVEL_Bt"

# list all data in scene folder
scene_dir_path <- paste(current_WD, scene_dir_name, sep="/")
(files_list <- list.files(scene_dir_path))

# set up patterns for delete
delete_patterns <- c(
  "B1.T", "B1_", "B2", "B3", "B6", "B7", "B8", "B9", "B11", "BQA"
  )

for (i in seq_along(files_list)){
  for (pattern in delete_patterns){
    if (grepl(pattern, files_list[i])){
      file.remove(paste(scene_dir_path, files_list[i], sep="/"))
      print(files_list[i])
      print("was deleted!")
    }
  }
}
