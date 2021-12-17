// A JavaScript Tutorial
// ****************************************************************

// Variable declaration
var i = 1;          // Number
var s = "world!";   // String

sayHello(s); // Function call

// Function declaration
function sayHello(param) {
    console.log("Hello, " + param);
}

// Multiline comment
/*
 ******************************************************************
*/

var bEnabled = false; // Boolean

// If bEnabled is true, sayHello is called.
bEnabled && sayHello("cosmos!");

s = "cosmos!";
sayHelloEx(s, "???");

function sayHelloEx(param, outputType = "msgbox") {
    var hello = "Hello, ";

    if (outputType == "msgbox") {
        alert(hello + param);
    } else { // "logmsg"...
        console.log(hello + param);
    }
}

// ****************************************************************

// Operator precedence
var expr1 = 2 * 2 + 2;   // 6
var expr2 = 2 * (2 + 2); // 8

var n = 0;
var sn = '0';
var v1 = null;
var v2 = undefined;

// Ternary expression
var bEnabled = (s != "cosmos!") ? true : false;

// Logical and relational operations
if (bEnabled && (i > 0 || n == 0)) {

    console.log(n === sn);

} else if (s == "cosmic!") {

    console.log(typeof v2);

} else {
    // Implicit type conversion
    expr3 = expr1 + "" + expr2; 
    console.log(expr3 + " (" + typeof expr3 + ")");
}

// ****************************************************************

var la = "A"; // Latin
var ga = "Α"; // Greek

console.log(la == ga);
console.log(getLetterDesc(la));
console.log(getLetterDesc(ga));

function getLetterDesc(letter) {
    // Conditional switch
    switch(letter) {
        case 'Α':
            o = "Greek capital letter Alpha.";
        break;

        case 'Ω':
            o = "Greek capital letter Omega.";
        break;

        default:
            o = "Unknown character.";
        break;
    }

    return o;
}

// ****************************************************************

var sayHelloIndirect = function(param, outputFunction) {
    var hello = "Hello, ";
    outputFunction(hello + param);
};

var logmsg = function(message) {
    console.log(message);
}

var msgbox = function(message) {
    alert(message);
}

// Equivalent to "console.log('Hello, ' +  s);"
sayHelloIndirect(s, logmsg);

// ****************************************************************

// Arrays
var aColors = ["red", "yellow"];

aColors[1] = "green";

aColors.push("blue");

console.log("Zero-based index of 'red': " + aColors.indexOf("red"));

// ****************************************************************

// For-loop (initialization; condition; increment/decrement)
for (var i = 1, output = []; i <= 5; i++) {
    output.push(i);
}
console.log(output.join(", "));

for (var i = aColors.length - 1; i >= 0; i--) {
    console.log(aColors[i]);
}

for (var i = 0;; i++) {
    // Remainder of division
    if (i % 2) {
        // Jump to the next iteration
        continue;

    // Loop condition
    } else if (i >= 10) {
        // Exit the loop
        break;
    }

    console.log(i) // Only even numbers
}

// While-loop
var i = 0;
while (i < aColors.length) {
    console.log(aColors[i]);
    ++i;
}

// Do-while-loop
var ready = false, count = 0, limit = 3;
do {
    count++

    if (count > limit) {
        ready = true
    }
} while (!ready)

// ****************************************************************

console.log("Time: " + getTime());

function getTime() {
    var d = new Date();
    var hours = zeroPad(d.getHours());
    var minutes = zeroPad(d.getMinutes());
    return hours + ":" + minutes;
}

function zeroPad(value) {
    return value < 10 ? "0" + value : value;
}

console.log("Random number: " + getRandomNumber(100));

function getRandomNumber(Max) {
    return Math.floor(Math.random() * Max) + 1;
}

// ****************************************************************

var Character = {
    'Name': undefined,

    'Walk': function() {
        console.log("Walking...");
        this.Stats.Speed++;
    },

    'Talk': function() {
        console.log("Talking...");
        this.Stats.Magic++;
    },

    'Fight': function() {
        console.log("Fighting...");
        this.Stats.Attack++;
        this.Stats.Defense++;
        this.Stats.Vitality -= getRandomNumber(10); // 1-10
    },

    'Sleep': function() {
        console.log("Sleeping...");
        this.Stats.Vitality += 3;
    },

    'Stats': {
        'Attack': 50,
        'Defense': 50,
        'Magic': 10,
        'Speed': 30,
        'Vitality': 100
    }
};

console.log("Vitality: " + Character.Stats.Vitality);
Character["Fight"]();
console.log("Vitality: " + Character.Stats.Vitality);

// ****************************************************************

// Regular expression
var temp = /world|cosmos!/.test(s);
if (temp) {
    console.log("String length:" + s.length);
}

// Browser information
console.log(navigator.userAgent);
//console.dir(window.navigator);

console.log("URL protocol: \"" + document.location.protocol + "\"");

// ****************************************************************
