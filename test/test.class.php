<?php

/**
 * An object that has a name
 *
 * (This only exists so PHPDocumentor has something to document when testing the script)
 */
class ThingWithAName {
	/**
	 * @var string The name of the object
	 */
	private $name;

	/**
	 * Sets the name of this object
	 *
	 * @param string $new_name The new name for this object
	 */
	public function setName($new_name) {
		$this->name = $new_name;
	}

	/**
	 * Gets the name of this object
	 *
	 * @return string The name of the object
	*/
	public function getName() {
		return $this->name;
	}
}
