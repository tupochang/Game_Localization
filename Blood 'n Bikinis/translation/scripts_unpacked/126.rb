#==============================================================================
# ** Linked_List (v1.0)                                       By Zeriab
#------------------------------------------------------------------------------
# Represents a doubled linked list.
# Has a reference to the tail and the head of the list
#============================================================================== 

class Linked_List
  #==========================================================================
  # * PUBLIC VISIBILITY
  #==========================================================================
  attr_reader :size
  
  # A Linked List can be considered as a enumerable collection
  # The head is considered as the first element and the tail the last
  include Enumerable
  
  #--------------------------------------------------------------------------
  # * Name      : Object Initialization
  #   Info      : Initializes the list by clearing it
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #--------------------------------------------------------------------------
  def initialize
    # Clears the list
    clear
  end
  #--------------------------------------------------------------------------
  # * Name      : Concatenation
  #   Info      : Returns a new array list by concatenating the two lists
  #               together to produce a third list.
  #   Author    : Zeriab
  #   Call Info : One Argument - The list to concatenate with.
  #   Comments  : Slow compared to the dangerous concatenation (.concat!)
  #--------------------------------------------------------------------------
  def +(list)
    return self.dup.concat!(list.dup)
  end
  #--------------------------------------------------------------------------
  # * Name      : Equality
  #   Info      : Tells whether the lists are equal or not
  #   Author    : Zeriab
  #   Call Info : One Argument - The list to concatenate with.
  #   Comments  : Two lists are equal if their heads and tails are equal on
  #               the Object level
  #--------------------------------------------------------------------------
  def ==(list)
    return self.head == list.head && self.tail == list.tail
  end
  #--------------------------------------------------------------------------
  # * Name      : Set nth element
  #   Info      : Sets the value of the nth element in the list
  #   Author    : Zeriab
  #   Call Info : Two Arguments - Numeric n for specifying which element
  #               Object value to replace the value of the nth element
  #   Comments  : Returns true if the change succeeds otherwise false
  #--------------------------------------------------------------------------
  def []=(n,value)
    element = get_element(n)
    # If nil is returned from get_element the element was not found
    if element.nil?
      return false
    else
      # Changes the value of the element
      element.value = value
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * Name      : Add Value
  #   Synonyms  : enqueue(value), insert(value), push(value), <<(value)
  #   Info      : Adds a value to the list as the new head
  #   Author    : Zeriab
  #   Call Info : One Argument - Object value to be added
  #   Comments  : Returns the modified list.
  #               Values in the list does not have to be distinct
  #--------------------------------------------------------------------------
  def add(value)
    element = Linked_List_Element.new
    element.value = value
    insert_element(element)
    self.size += 1
    return self
  end
  # Synonyms
  def enqueue(value) add(value) end
  def insert(value) add(value) end
  def push(value) add(value) end
  def <<(value) add(value) end
    
  #--------------------------------------------------------------------------
  # * Name      : Clear
  #   Info      : Clears the list (no elements present afterwards
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #--------------------------------------------------------------------------
  def clear
    self.size = 0
    self.tail = nil
    self.head = nil
  end
  #--------------------------------------------------------------------------
  # * Name      : Concatenation!
  #   Info      : Adds the given list to the tail
  #   Author    : Zeriab
  #   Call Info : One Argument - The list to concatenate with.
  #   Comments  : Alters the given list as well.
  #--------------------------------------------------------------------------
  def concat!(list)
    if list.size <= 0
      # The given list is empty
      return self
    elsif self.size <= 0
      # This list is empty
      self.tail = list.tail
      self.head = list.head
      self.size = list.size
      return self
    end
    # Neither list are empty
    self.tail.next_element = list.head
    list.head.previous_element = self.tail
    self.size += list.size
    self.tail = list.tail
    return self
  end
  #--------------------------------------------------------------------------
  # * Name      : Duplication
  #   Info      : Duplicates the list
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #   Comments  : Duplicates the list by creating a new instance of the same
  #               class and adding the values in the same order as they are
  #               in this list
  #--------------------------------------------------------------------------
  def dup
    list = self.class.new
    self.each {|value| list.unshift(value)}
    return list
  end
  #--------------------------------------------------------------------------
  # * Name      : Clone
  #   Info      : Clones the list
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #   Comments  : New list elements are created. The values are not cloned
  #--------------------------------------------------------------------------
  def clone
    list = super
    list.clear
    self.each {|value| list.unshift(value)}
    return list
  end
  #--------------------------------------------------------------------------
  # * Name      : Delete
  #   Info      : Deletes the first occurrence of a value from the list
  #   Author    : Zeriab
  #   Call Info : One Argument - The value to delete.
  #   Comments  : Complexity of O(n), where n is the number of elements in the
  #               list, since a search is needed
  #               Returns nil if the value does not exist in the list
  #--------------------------------------------------------------------------
  def delete(value)
    # Searches for the first element containing the value
    element = self.search(value)
    if element.nil?
      # No element was found, so nil is returned
      return nil
    else
      # Deletes the element from the list and returns its value
      self.delete_element(element)
      self.size -= 1
      return element.value
    end
  end
  #--------------------------------------------------------------------------
  # * Name      : Each
  #   Info      : The each method required by the Enumerable module
  #   Author    : Zeriab
  #   Call Info : Refer to the documentation on the Enumerable module
  #--------------------------------------------------------------------------
  def each
    # Return if there are no elements in the list
    return if self.head.nil?
    # Yield the first value of the list (The head)
    element = self.head
    yield element.value
    # Run through the list until the tail is fount or the next element of the
    # list is nil
    while element != self.tail && element.next_element != nil
      # Retrieve and yield the next element in the list
      element = element.next_element
      yield element.value
    end
  end
  #--------------------------------------------------------------------------
  # * Name      : Empty?
  #   Info      : Checks if the list is empty.
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #   Comments  : A list is empty if it has size 0
  #--------------------------------------------------------------------------
  def empty?
    return self.size <= 0
  end
  #--------------------------------------------------------------------------
  # * Name      : First
  #   Synonyms  : peek
  #   Info      : Retrieves the first value of the list (head)
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #   Comments  : Returns nil if the list is empty
  #--------------------------------------------------------------------------
  def first
    return nil if self.empty?
    return self.head.value
  end
  # Synonyms
  def peek() return first end
  
  #--------------------------------------------------------------------------
  # * Name      : Get
  #   Synonyms  : [](n) - Like with an array
  #   Info      : Gets the nth element in the list (0 = first value)
  #   Author    : Zeriab
  #   Call Info : One Argument - The value to delete.
  #   Comments  : Returns nil if the list does not have enough elements
  #--------------------------------------------------------------------------
  def get(n)
    element = get_element(n)
    # Return nil if there is not nth element in the list
    if element.nil?
      return nil
    end
    return element.value
  end
  # Synonyms
  def [](n) get(n) end
  
  #--------------------------------------------------------------------------
  # * Name      : Inspect
  #   Info      : Returns a string representation of the list
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #--------------------------------------------------------------------------
  def inspect
    return self.join(" => ")
  end
  #--------------------------------------------------------------------------
  # * Name      : Join
  #   Info      : Returns a string created by converting each value in the
  #               list to a string, separated by the given separator string.
  #   Author    : Zeriab
  #   Call Info : Zero to One Argument - The separator string, by default ""
  #--------------------------------------------------------------------------
  def join(separator = "")
    self.to_a.join(separator)
  end
  #--------------------------------------------------------------------------
  # * Name      : Last
  #   Info      : Retrieves the last value of the list (tail)
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #   Comments  : Returns nil if the list is empty
  #--------------------------------------------------------------------------
  def last
    return nil if self.empty?
    return self.tail.value
  end
  
  # Synonym for size
  def length() return size end
    
  #--------------------------------------------------------------------------
  # * Name      : Map!
  #   Synonyms  : collect!(&block)
  #   Info      : Invokes block once for the value each element list.
  #   Author    : Zeriab
  #   Call Info : One block - The block to call with each value
  #   Comments  : Replaces the elements values with the value returned
  #               by the block.
  #--------------------------------------------------------------------------
  def map!(&block)
    # Return if there are no elements in the list
    return if self.head.nil?
    element = self.head
    element.value = block.call element.value
    while element != self.tail && element.next_element != nil
      element = element.next_element
      element.value = block.call element.value
    end
    return self
  end
  # Synonym
  def collect!(&block) map!(&block) end
  
  #--------------------------------------------------------------------------
  # * Name      : Number of Items
  #   Info      : Finds the number of non-nil values in the list
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #--------------------------------------------------------------------------
  def nitems
    number = 0
    # Return if there are no elements in the list
    return number if self.head.nil?
    element = self.head
    number += 1  if !element.value.nil?
    while element != self.tail && element.next_element != nil
      element = element.next_element
      number += 1  if !element.value.nil?
    end
    return number
  end
  #--------------------------------------------------------------------------
  # * Name      : Pop
  #   Synonyms  : dequeue
  #   Info      : Deletes the head of the list and returns its value.
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #   Comments  : Returns nil if the list is empty
  #--------------------------------------------------------------------------
  def pop
    # Return nil if the list is empty
    if self.head.nil?
      return nil
    end
    self.size -= 1
    return delete_element(self.head).value
  end
  # Synonyms
  def dequeue() return pop end
  
  #--------------------------------------------------------------------------
  # * Name      : Replace
  #   Info      : Replaces the list to have the contents of the given list
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #--------------------------------------------------------------------------
  def replace(list)
    list_temp = list.clone
    self.head = list_temp.head
    self.tail = list_temp.tail
    self.size = list_temp.size
    return self
  end
  #--------------------------------------------------------------------------
  # * Name      : Shift
  #   Info      : Deletes the tail of the list and returns its value.
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #   Comments  : Returns nil if the list is empty
  #--------------------------------------------------------------------------
  def shift
    # Return nil if the list is empty
    if self.head.nil?
      return nil
    end
    self.size -= 1
    return delete_element(self.tail).value
  end
  #--------------------------------------------------------------------------
  # * Name      : To_s
  #   Info      : Returns list.join
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #--------------------------------------------------------------------------
  def to_s
    return join
  end
  #--------------------------------------------------------------------------
  # * Name      : Unshift
  #   Info      : Adds an object to the tail of the list
  #   Author    : Zeriab
  #   Call Info : No Arguments
  #--------------------------------------------------------------------------
  def unshift(value)
    element = Linked_List_Element.new
    element.value = value
    insert_element_tail(element)
    self.size += 1
  end
  
  #==========================================================================
  # * PROTECTED VISIBILITY
  #==========================================================================
  protected
  attr_accessor :head
  attr_accessor :tail
  
  ##
  # Sets the size of the list
  #
  def size=(value)
    @size = value if value >= 0
  end
  
  #==========================================================================
  # * PRIVATE VISIBILITY
  #==========================================================================
  private
  
  ##
  # Insert an element into the list.
  # Assumes 'element' is a Linked_List_Element.
  #
  def insert_element(element)
    if head.nil?
      self.head = element
      self.tail = element
      return
    end
    element.next_element = self.head
    self.head.previous_element = element
    self.head = element
    element.previous_element = nil
  end
  
  ##
  # Insert an element into the list at the tail.
  # Assumes 'element' is a Linked_List_Element.
  #
  def insert_element_tail(element)
    if head.nil?
      self.head = element
      self.tail = element
      return
    end
    
    element.previous_element = self.tail
    self.tail.next_element = element
    self.tail = element
    element.next_element = nil
  end
  
  ##
  # Delete the given element from the list
  # Assumes 'element' is a Linked_List_Element.
  #
  def delete_element(element)
    if element.next_element.nil?
      self.tail = element.previous_element
    else
      element.next_element.previous_element = element.previous_element
    end
    
    if element.previous_element.nil?
      self.head = element.next_element
    else
      element.previous_element.next_element = element.next_element
    end
    
    return element
  end
  
  ##
  # Search for an element with the specified value.
  # Return the first element found with the corresponding value
  # Return nil if no element is found.
  #
  def search(value)
    # If the head is nil the list is empty
    if self.head.nil?
      return nil
    end
    # Start with the head
    element = self.head
    loop do
      # Check if the element has the correct value
      if element.value == value
        return element
      end
      # Return nil if the tail has been reached
      if element == self.tail 
        return nil
      end
      # Look at the next element in the list
      element = element.next_element
    end
  end
  
  ##
  # Get the object at the nth element in the list
  #
  def get_element(n)
    # Return nil if the list is empty (or n out of the range 0...size)
    if self.head.nil? || n < 0 || n > size
      return nil
    end
    # Searches for the nth element
    element = self.head
    for i in 0...n 
      if self.tail == element
        # End of list reached without getting to the nth element
        return nil
      end
      element = element.next_element
    end
    # Returns the found element
    return element
  end
  
  ##
  # Represents an element in the linked list.
  #
  class Linked_List_Element
    attr_accessor :value
    attr_accessor :previous_element
    attr_accessor :next_element
  end
end