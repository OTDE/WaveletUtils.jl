export
    isvalidtree, fulltree, transformtree

function isvalidtree(signal, tree::BitVector)
    maxlevels = levelmax(signal)
    treesize = length(tree)
    treesize == (1 << maxlevels) - 1 || return false
    maxleaf = ((1 << (maxlevels - 1)) - 1)
    @assert maxleaf << 1 + 1 <= treesize
    leaves = firstindex(tree):maxleaf
    return all(leaves) do leaf
        return @inbounds tree[leaf] || !(tree[leaf << 1] || tree[leaf << 1 + 1])
    end
end

function maketree(signal, level)
    maxlevels = levelmax(signal)
    treesize = (1 << maxlevels) - 1
    maxleaf = ((1 << (maxlevels - 1)) - 1)
    @assert 0 <= level <= maxlevels
    @assert maxleaf << 1 + 1 <= treesize
    tree = falses(treesize)
    return tree
end

function fulltree(signal, level)
    tree = maketree(signal, level)
    return filltree!(tree, level)
end

function filltree!(tree, level)
    @inbounds for leaf in 1:((1 << level) - 1)
        tree[leaf] = true
    end
    return tree
end

function transformtree(signal, level)
    tree = maketree(signal, level)
    return transformtree!(tree, level)
end

function transformtree!(tree, level)
    @inbounds for eachlevel in 1:level
        tree[(1 << eachlevel) - 1] = true
    end
    return tree
end