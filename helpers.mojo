from pathlib import Path
import os

alias SEP = "/"  # obviously, this will probably won't works on Windows. Should add something like if os.is_windows() with the correct value

fn set_extension(filename : Path, ext : String) -> Path:
    var t = filename.suffix()
    var l = len(t)
    var txt = filename.__str__()
    if l==0:
        if txt[l-1]==".":
            return Path(txt+ext)    
        else:
            return Path(txt+"."+ext)
    else:
        return Path(txt[0:-l]+"."+ext)

fn create_path_if_not_exists(filename : Path) raises:
    """
        create missing part of the directory of a file
        doesn't work with things like dir1/../../dir2/filename.jpg
        maybe later when I'll get more time for that kind of things
        .
    """
    var tmp = filename.__str__()
    var idx = tmp.find(SEP,0)
    while idx>0:
        var tmp_path = Path(tmp[0:idx])
        if tmp_path.is_dir() == False:
            os.mkdir(tmp)
        idx = tmp.find(SEP,idx+1)

fn get_file_path(filename : Path) -> Path:
    """
        return the path of a filename, if possible. If not return an empty path
        doesn't work with things like dir1/../../dir2/filename.jpg
        .
    """
    var tmp = filename.__str__()
    var idx = tmp.rfind(SEP)
    if idx>0:
        return Path(tmp[0:idx])
    else:
        return Path("")

fn random_filename(num_chars : Int) -> String:
    """
        return a random filename, with or without extension, of num_chars length.
    """
    var valid_chars = String(String.ASCII_LETTERS+"_-"+String.DIGITS)
    var max = len(valid_chars)
    var mem = DTypePointer[DType.int32]().alloc(num_chars)
    random.seed()
    random.randint[DType.int32](mem, size=num_chars, low=0, high=max-1)
    var result = String()    
    for n in range(num_chars):
        var x = mem[n]
        result += valid_chars.__getitem__(Int(x.value))  # seems highly inefficient
    mem.free()
    return result

fn random_path(num_blocks : Int) -> Path:
    """
        return a random path, without extension, of num_chars elements.
        each element has a length of 3 to 15 characters.
        the returned path is relative, meaning it doesn't starts with /
        so it could be joined to gettempdir()
        .
    """
    var mem = DTypePointer[DType.int32]().alloc(num_blocks)
    random.seed()
    random.randint[DType.int32](mem, size=num_blocks, low=3, high=15)
    var filepath = random_filename(8)
    for n in range(num_blocks-1):
        var x = Int(mem[n].value)
        filepath = os.path.path.join(filepath,random_filename(x))    
    mem.free()
    return Path(filepath)    

fn compare_files(file_a : Path, file_b : Path) raises -> Bool:
    var result = file_a.is_file() and file_b.is_file()
    if result:
        var size_a = file_a.stat().st_size
        var size_b = file_b.stat().st_size
        result = size_a == size_b
        if result:
            var bytes_a = List[UInt8](capacity=size_a)
            with open(file_a, "rb") as f:
                bytes_a = f.read_bytes()
            var bytes_b = List[UInt8](capacity=size_b)
            with open(file_a, "rb") as f:
                bytes_b = f.read_bytes()
            for i in range(size_a):
                result = bytes_a.__getitem__(i) == bytes_b.__getitem__(i)
                if not result:
                    break
    return result    


