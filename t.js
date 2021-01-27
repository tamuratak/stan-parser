{
    function leftAssociate(leftTerm, rightTermArrayArg) {
        const termArray = rightTermArrayArg.flat().filter(e => e);
        if (termArray.length <= 2) {
            const right = termArray[1];
            const op = termArray[0];
            return {
                left: leftTerm, right, op
            };
        } else {
            const right = termArray[termArray.length - 1];
            const op = termArray[termArray.length - 2];
            const rest = termArray.slice(0, termArray.length - 2);
            const left = leftAssociate(leftTerm, rest);
            return { left, right, op }
        }
    }
}