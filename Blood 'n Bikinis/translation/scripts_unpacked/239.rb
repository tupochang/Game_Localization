


class DA


  ###########################################################
  ###########################################################

  def self.file_open(path, mode="r")
    return self.f_open(path, mode)
  end


  def self.file_write(file, contenu="", mode="w")
    if file.is_a?(IO) == false
      file = self.file_open(file, mode)
      need_close = true
    else
      raise("c'est IO")
    end
    res = file.write(contenu)
    if need_close == true
      file.close
    end
  end


  def self.file_close(file)
    file.close
  end


  def self.file_read(path, mode="r")
    return self.lire_fichier(path, mode)
  end


  def self.file_read_lines(path, mode="r")
    
    f = self.f_open(path, mode)

    begin
      contenu = f.readlines
    rescue
      raise(DAE_File_Read.new(path))
    end

    self.file_close(f)

    return contenu

  end

  
  def self.f_open(path, mode)
    begin
      f = File.open(path, mode)
    rescue Errno::ENOENT => e
      raise(DAE_File_Not_Found.new(path))
    rescue
      raise(DAE_File_Open.new(path))
    end
    return f
  end


  def self.file_exists?(path, extension=true)
    if extension == true
      return File.exists?(path)
    end

    # On supprime l'extension du chemin
    path = File.no_extname(path)

    # On regarde si ce chemin existe
    return (file_list(path+".*")).size > 0
  end

  def self.file_list(path)
    if path.include?("*") == false
      path = path.join("*")
    end
    return Dir[path]
  end

  def self.file_list_basename(path)
    list = self.file_list(path)
    list.collect!{|x|
      x = x.basename
    }
  end

  def self.file_path(path)
    # On supprime l'extension du chemin
    path = File.no_extname(path)

    # On retourne le premier fichier avec cette extension
    return (file_list(path+"*"))[0]
  end

  # On retourne si le fichier existe en regardant le début du nom
  def self.file_exists_begin?(path)
    files = Dir.entries(path.dirname)
    path2 = path.basename.gsub('.', '\\.')
    reg = Regexp.new(path2)
    files.keep_reg(reg)
    return files.size > 0
  end

  def self.file_first(path)
    return (self.file_list(path))[0]
  end

  def self.file_directory?(path)
    return File.directory?(path)
  end



  def self.file_rename(path1, path2)
    if path1.is_a?(Regexp)
      list = self.file_list(Dir.pwd)
      list.keep_reg(path1)
      for file in list
        str = file.subreg(path1, path2)
        #pa "str", str
        self.file_rename(file, str)
      end
      return list
    end
    #pa path1, path2
    return File.rename(path1, path2)
  end

  def self.file_delete(path)
    File.delete(path)
  end

  def self.file_delete_secure(path)
    if file_exists?(path)
      file_delete(path)
    end
  end

  def self.files_delete(array)
    for path in array
      self.file_delete(path)
    end
  end


  def self.file_copy(path_avant, path_apres)
    FileUtils.cp(path_avant, path_apres)
  end


  def self.file_comp(path_1, path_2)
    contenu_1 = self.file_read(path_1, "rb")
    contenu_2 = self.file_read(path_2, "rb")
    return contenu_1 == contenu_2
  end


  def self.mkdir(path)
    begin
      FileUtils.mkdir_p(path)
    rescue Errno::EEXIST
      raise(DAE_Dir_Create.new(path))
    end
  end

  def self.file_crc32(path)
    c = self.file_read(path, "rb")
    return Zlib::crc32(c)
  end


  ###########################################################
  # Lecture sur le disque
  ###########################################################


  # Lit un objet Ruby dans un fichier à l'aide de Marshal
  #  path : chemin du fichier
  #
  def self.lire_marshal(path)

    f = self.f_open(path, "r")
  
    begin
      objet = Marshal.load(f)
    rescue
      raise(DAE_Marshal_Read.new(path))
    end

    self.file_close(f)

    return objet

  end


  def self.marshal_read(path)
    return self.lire_marshal(path)
  end


  def self.marshal_read_pos(path, pos=0)
    begin
      f = self.f_open(path, "rb")
    rescue Errno::ENOENT
      raise(DAE_File_Not_Found.new(path))
    rescue
      raise(DAE_Marshal_Open.new(path))
    end

    # On passe les éléments qui ne nous intéressent pas
    begin
      for i in 0...pos
        Marshal.load(f)
      end
    rescue
      raise(DAE_Marshal_Read_Pos.new(path, i))
    end
  
    begin
      objet = Marshal.load(f)
    rescue
      raise(DAE_Marshal_Read_Pos.new(path, pos))
    end

    self.file_close(f)

    return objet

  end


  def self.marshal_write(path, objet, mode="w")
    ecrire_marshal(path, objet, mode)
  end

  def self.marshal_write_add(path, objet)
    ecrire_marshal(path, objet, "a")
  end


  # Renvoie le contenu d'un fichier
  #  path : chemin du fichier
  #
  def self.lire_fichier(path, mode="r")

    f = self.f_open(path, mode)

    begin
      contenu = f.read
    rescue
      raise(DAE_File_Read.new(path))
    end

    self.file_close(f)

    return contenu

  end






  ###########################################################
  # Ecriture sur le disque
  ###########################################################

  # Ecrit un fichier sur le disque
  def self.ecrire_fichier(path, contenu, mode="w")

    f = self.f_open(path, mode)


    begin
      f.write(contenu)
    rescue
      raise(DAE_File_Write.new(path))
    end


    self.file_close(f)

  end



  # Ecrit un objet Ruby dans un fichier à l'aide de Marshal
  #  path : chemin du fichier
  #  objet : objet Ruby concerné
  #
  def self.ecrire_marshal(path, objet, mode="w")

    f = self.f_open(path, mode)



    begin
      Marshal.dump(objet, f)
    rescue
      raise(DAE_Marshal_Write.new(path))
    end

    self.file_close(f)

    return true

  end



  ###########################################################
  # Listage de fichiers et dossiers
  ###########################################################

  def self.files_reg(path, reg_f, absolu=false)
    return Dir::files_reg(path, reg_f, false, absolu)
  end





  # Vérifie l'existence d'un dossier, et envoie une exception si celui-ci
  # n'existe pas
  #
  def self.verifier_dossier(path)
    #p path
    if File.directory?(path) == false
      raisee("#99 Le dossier %s n'existe pas.", path)
    end
  end



  ###########################################################
  ###########################################################


  def self.dir_empty(path)

    self.verifier_dossier(path)

    entries = Dir.entries(path)
    nb = 0
    for entry in entries
      file = path.join(entry)
      next if DA::file_directory?(file) == true
      DA::file_delete(file)
      nb += 1
    end

    return nb
  end


end