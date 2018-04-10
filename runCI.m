function runCI

try
    import('matlab.unittest.TestRunner');
    import('matlab.unittest.plugins.CodeCoveragePlugin');
    import('matlab.unittest.plugins.TAPPlugin');
    import('matlab.unittest.plugins.ToFile');
    import('matlab.unittest.plugins.codecoverage.CoberturaFormat');
    
    
    runner = TestRunner.withTextOutput;
    runner.addPlugin(CodeCoveragePlugin.forFolder('core','IncludingSubfolders',true, ...
        'Producing', CoberturaFormat('coverage.xml')))
    runner.addPlugin(TAPPlugin.producingVersion13(ToFile('testResults.tap')));
    runner.run(testsuite('tests', 'IncludeSubfolders', true));
    
catch e
    disp(e.getReport('extended'))
    exit(1);
end
exit(0);
