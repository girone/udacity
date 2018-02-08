def classify(features_train, labels_train):
    
    ### your code goes here--should return a trained decision tree classifer
    from sklearn import tree
    classifier = tree.DecisionTreeClassifier(min_samples_split=50)
    classifier.fit(features_train, labels_train)  
    
    return classifier