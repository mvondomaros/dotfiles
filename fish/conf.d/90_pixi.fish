if [ -d ~/.pixi ]
    fish_add_path ~/.pixi/bin
    for file in ~/.pixi/completions/fish/*
        source $file
    end
end
