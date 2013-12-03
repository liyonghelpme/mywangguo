heapq = {}
-- 整数小堆排序
function heapq.heappush(list, item)
    table.insert(list, item)
    local i = #list
    local curPos = i 
    local parent = math.floor(i/2)
    while parent > 0 do
        if list[curPos] < list[parent] then
            list[curPos], list[parent] = list[parent], list[curPos]
        else
            break
        end
        curPos, parent = parent, math.floor(parent/2)
    end
end
function heapq.heappop(list)
    list[1], list[#list] = list[#list], list[1]
    local pop = table.remove(list)
    local curPos = 1
    local left = curPos*2
    local right = curPos*2+1
    while true do
        local state = 0 -- 0parent最小 1左最小 2右最小 
        local min = curPos
        if left <= #list then
            if list[min] > list[left] then
                state = 1
                min = left
            end
        end
        if right <= #list then
            if list[min] > list[right] then
                state = 2
                min = right
            end
        end
        if state == 0 then
            break
        elseif state == 1 then
            list[curPos], list[left] = list[left], list[curPos]
            curPos, left, right = left, left*2, left*2+1
        elseif state == 2 then
            list[curPos], list[right] = list[right], list[curPos]
            curPos, left, right = right, right*2, right*2+1
        end
    end
    return pop
end
function heapq.printHeap(list)
    print("heap")
    for i, v in ipairs(list) do
        print("list", i, v)
    end
end

--[[ TestCase
input = {3, 5, 9, 1, 2, 10}
myList = {}
for k, v in ipairs(input) do
    heapq.heappush(myList,v)
    heapq.printHeap(myList)
end

while #myList > 0 do
    local pop = heapq.heappop(myList)
    print("pop", pop)
    heapq.printHeap(myList)
end
]]--
