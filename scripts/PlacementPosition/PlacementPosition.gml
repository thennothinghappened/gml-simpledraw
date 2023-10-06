enum Placement {
    Start, Middle, End
}

/// @param {number} start
/// @param {number} finish
function Position(start, finish) constructor {
    self.start = start;
    self.finish = finish;
}

/// @param {number} vertical
/// @param {number} horizontal
function Size(vertical, horizontal) constructor {
    self.vertical = vertical;
    self.horizontal = horizontal;
}

/// Attempts to place an element within a container so that it does not exceed the boundry, if possible.
/// @param {number} amount The amount (between 0 and 1) to scale across the axis
/// @param {number} src_size the size of the source element
/// @param {number} dest_size the size of the destination element
/// @returns {Position}
function placement_get_on_axis(amount, src_size, dest_size) {
    var middle = dest_size * amount;
    var half_src = (src_size / 2);
    
    var start = middle - half_src;
    var finish = middle + half_src;
    
    var side_affinity = amount < 0.5 ? Placement.Start : Placement.End;
    
    if (amount == 0.5) {
        side_affinity = Placement.Middle;
    }
    
    switch (side_affinity) {
        
        case Placement.Start: {
            if (start >= 0) {
                return new Position(start, finish);
            }
            
            return new Position(0, src_size);
        }
        
        case Placement.Middle: {
            return new Position(start, finish);
        }
        
        case Placement.End: {
            if (finish <= dest_size) {
                return new Position(start, finish);
            }
            
            var diff = finish - dest_size;
            return new Position(start - diff, finish - diff);
        }
    }
    
}

/// Place a position correctly within another.
/// @param {number} vertical
/// @param {number} horizontal
/// @param {Size} src
/// @param {Size} dest
/// @returns {Vec2<Position>}
function placement_get(vertical, horizontal, src, dest) {
    var hplace = placement_get_on_axis(horizontal, src.horizontal, dest.horizontal);
    var vplace = placement_get_on_axis(vertical, src.vertical, dest.vertical);
    
    return new Vec2(hplace, vplace);
}

/// Place a position correctly within another.
/// @param {Placement} vertical
/// @param {Placement} horizontal
/// @param {Size} src
/// @param {Size} dest
/// @returns {Vec2<Position>}
function placement_get_fancy(vertical, horizontal, src, dest) {
    return placement_get(vertical / 2, horizontal / 2, src, dest);
}